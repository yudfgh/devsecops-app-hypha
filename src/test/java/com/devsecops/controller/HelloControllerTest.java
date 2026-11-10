package com.devsecops.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(HelloController.class)
class HelloControllerTest {

    @Autowired
    private MockMvc mvc;

    @Test
    void helloReturnsGreeting() throws Exception {
        mvc.perform(get("/api"))
                .andExpect(status().isOk())
                .andExpect(content().string("Hello from DevOps project! "));
    }

    @Test
    void unknownPathReturns404() throws Exception {
        mvc.perform(get("/does-not-exist"))
                .andExpect(status().isNotFound());
    }
}
