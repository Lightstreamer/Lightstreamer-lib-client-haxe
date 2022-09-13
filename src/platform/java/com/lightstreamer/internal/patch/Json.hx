package com.lightstreamer.internal.patch;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;

abstract Json(JsonNode) to JsonNode from JsonNode {
  static final mapper: ObjectMapper = new ObjectMapper();

  public function new(str: String) {
    this = mapper.readTree(str);
  }

  public function apply(patch: JsonPatch): Json {
    return com.flipkart.zjsonpatch.JsonPatch.apply(patch, this);
  }

  public function toString(): String {
    return mapper.writeValueAsString(this);
  }
}

typedef JsonPatch = Json;