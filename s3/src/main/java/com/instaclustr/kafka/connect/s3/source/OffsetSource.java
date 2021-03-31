package com.instaclustr.kafka.connect.s3.source;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Collections;
import java.util.Map;
import java.util.Properties;
import java.util.stream.Collectors;

import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.OffsetAndMetadata;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.connect.errors.ConnectException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.instaclustr.kafka.connect.s3.AwsStorageConnectorCommonConfig;

public class OffsetSource {
    private static final Logger log = LoggerFactory.getLogger(OffsetSource.class);
    Properties consumerConfig = new Properties();

    public OffsetSource() {
        this.consumerConfig = getAdminClientConfig();
    }
    /* Setting kafka admin configuration for kafka consumer */

    private Properties getAdminClientConfig() {
        Properties adminProps = new Properties();
        try {
            adminProps.load(new FileInputStream(AwsStorageConnectorCommonConfig.CONNECT_DISTRIBUTED_PROPERTIES));
            adminProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
            adminProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        } catch (IOException e) {
            throw new ConnectException(e);
        }
        return adminProps;
    }
    /*
     * Offset transformation logic:
     * 1) Initialize all consumer offset to 0
     * 2) Process only consumer group offset > lastReadOffset
     * 3) consumerGroupOffset = offset > totalRecords ? totalRecords : offset
     *
     * <scenario-1> 
     * Mode="backup", Topic="identities", Total records = 20, Group1 = 5 offset, Group2 = 20 offset, beginning offset=0
     * Mode="restore", Topic="identities", Total records = 20, Group1 = 5 offset, Group2 = 20 offset, beginning offset=0
     *
     * <scenario-2> 
     * Mode="backup", Topic="identities", Total records = 20, Group1 = 5 offset (from #1), Group2 = 40 offset, beginning offset=20
     * Mode="restore", Topic="identities", Total records = 20, Group1 = 0 offset, Group2 = 20 offset, beginning offset=0
     */

    public void syncGroupForOffset(TopicPartition topicPartition, Map<String, Long> consumerGroups, Long lastReadOffset, Long totalRecords) {
        log.debug("topic partition : {}, lastReadOffset {} ", topicPartition, lastReadOffset);
        Properties groupConsumerConfig = consumerConfig;

        Map<String, Long> consumerGroupsResult = consumerGroups.entrySet().stream().filter(map -> map.getValue().longValue() > 
                lastReadOffset && !map.getKey().contains(AwsStorageConnectorCommonConfig.SINK_TP_TOTALRECORDS)
        ).collect(Collectors.toMap(map -> map.getKey(), map -> map.getValue()));

        for (Map.Entry<String, Long> entry : consumerGroupsResult.entrySet()) {
            String group = entry.getKey();
            Long offset = entry.getValue();
            groupConsumerConfig.put("group.id", group);
            Consumer<byte[], byte[]> consumer = new KafkaConsumer<>(groupConsumerConfig);
            consumer.assign(Collections.singletonList(topicPartition));

            Long consumerGroupOffset = offset > totalRecords ? totalRecords : offset;
            OffsetAndMetadata offsetAndMetadata = new OffsetAndMetadata(consumerGroupOffset);
            Map<TopicPartition, OffsetAndMetadata> offsets = Collections.singletonMap(topicPartition, offsetAndMetadata);
            consumer.commitSync(offsets);
            consumer.close();
            log.debug("Committed offset {} for group {}, topic {} and partition {}", offsets.get(topicPartition).offset(), group, topicPartition.topic(), topicPartition.partition());
        }
    }
}
