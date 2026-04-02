package com.ldpst.queueforge;

import org.springframework.boot.SpringApplication;

public class TestQueueforgeApplication {

	public static void main(String[] args) {
		SpringApplication.from(QueueforgeApplication::main).with(TestcontainersConfiguration.class).run(args);
	}

}
