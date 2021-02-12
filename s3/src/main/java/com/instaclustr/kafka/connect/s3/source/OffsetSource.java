package com.instaclustr.kafka.connect.s3.source;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.OffsetAndMetadata;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.connect.errors.ConnectException;

import com.instaclustr.kafka.connect.s3.AwsStorageConnectorCommonConfig;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OffsetSource {
	private static final Logger log = LoggerFactory.getLogger(OffsetSource.class);
	Properties consumerConfig = new Properties();
	
	public OffsetSource() {
		this.consumerConfig = getAdminClientConfig();
	}
	/*
	 * setting kafka admin configuration for kafka consumer
	 * 
	 */
	private Properties getAdminClientConfig() {
		  Properties adminProps = new Properties(); 
			  try {
					adminProps.load(new FileInputStream(AwsStorageConnectorCommonConfig.CONNECT_DISTRIBUTED_PROPERTIES));
					adminProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG,StringDeserializer.class.getName());
					adminProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,StringDeserializer.class.getName());
				} catch (IOException  e) {
					throw new ConnectException(e);
				} 
			  return adminProps;
		}
	   

	/*
	 * Offset transformation logic:
	 * 
	 * CurrentOffset = ConsumerGroupOffset - TopicPartitionBeginningOffset If
	 * CurrentOffset < 0 then 0 else CurrentOffset 
	 * 
	 * <Senario> The consumer group is
	 * stopped and some of offset is deleted and pointing beginning offset for
	 * TopicPartition is higher then consumer group offset
	 * 
	 * consumerGroupOffset = CurrentOffset If consumerGroupOffset > totalRecords
	 * then totalRecords else consumerGroupOffset 
	 * 
	 * <Senario> Offsets are going to
	 * commit in batches.
	 */

	
	    public void syncGroupForOffset(TopicPartition topicPartition, Map<String,Long> consumerGroups,Long beginningOffset,Long totalRecords) {
	    	log.info("topic partition : {}, beginningOffset {} ",topicPartition, beginningOffset);
	    	 for (Map.Entry<String, Long> entry : consumerGroups.entrySet()) {
	    		 
	                String group = entry.getKey();
	                Long offset = entry.getValue();
	                Properties groupConsumerConfig = consumerConfig;
	                groupConsumerConfig.put("group.id", group);
	                Consumer<byte[], byte[]> consumer = new KafkaConsumer<>(groupConsumerConfig);
	                consumer.assign(Collections.singletonList(topicPartition));
	                
	                Long consumerGroupOffset = (offset-beginningOffset)< 0 ? 0L : offset-beginningOffset;
	                consumerGroupOffset = consumerGroupOffset > totalRecords?totalRecords:consumerGroupOffset;
	                
	                OffsetAndMetadata offsetAndMetadata = new OffsetAndMetadata(consumerGroupOffset);
	                Map<TopicPartition, OffsetAndMetadata> offsets = Collections.singletonMap(topicPartition, offsetAndMetadata);
	                consumer.commitSync(offsets);
	                consumer.close();
	                log.debug("Committed offset {} for group {}, topic {} and partition {}",
	                		offsets.get(topicPartition).offset(), group, topicPartition.topic(), topicPartition.partition());
	               
	            }
	    }

}
