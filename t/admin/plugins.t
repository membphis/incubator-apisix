#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
use t::APISIX 'no_plan';

repeat_each(1);
no_long_string();
no_root_location();
no_shuffle();
log_level("info");

run_tests;

__DATA__

=== TEST 1: get the list of plugins
--- request
GET /apisix/admin/plugins
--- response_body_like eval
qr/\["limit-req","limit-count","limit-conn","key-auth","basic-auth","prometheus","node-status","jwt-auth","zipkin","ip-restriction","grpc-transcode","serverless-pre-function","serverless-post-function","openid-connect","proxy-rewrite","redirect","response-rewrite","fault-injection","udp-logger","wolf-rbac","proxy-cache","tcp-logger","proxy-mirror","kafka-logger","cors","syslog","batch-requests","http-logger"\]/
--- no_error_log
[error]



=== TEST 2: get plugin limit-req schema
--- request
GET /apisix/admin/plugins/limit-req
--- response_body
{"properties":{"rate":{"minimum":0,"type":"number"},"burst":{"minimum":0,"type":"number"},"key":{"enum":["remote_addr","server_addr","http_x_real_ip","http_x_forwarded_for"],"type":"string"},"rejected_code":{"minimum":200,"type":"integer"}},"required":["rate","burst","key","rejected_code"],"type":"object"}
--- no_error_log
[error]



=== TEST 3: get plugin node-status schema
--- request
GET /apisix/admin/plugins/node-status
--- response_body
{"additionalProperties":false,"type":"object"}
--- no_error_log
[error]



=== TEST 4: get plugin heartbeat schema
--- request
GET /apisix/admin/plugins/heartbeat
--- response_body
{"additionalProperties":false,"type":"object"}
--- no_error_log
[error]



=== TEST 5: get plugin limit-count schema
--- request
GET /apisix/admin/plugins/limit-count
--- response_body eval
qr/"required":\["count","time_window","key","rejected_code"]/
--- no_error_log
[error]



=== TEST 6: serverless-pre-function
--- config
location /t {
    content_by_lua_block {
        local t = require("lib.test_admin").test
        local code, body = t('/apisix/admin/plugins/serverless-pre-function',
            ngx.HTTP_GET,
            nil,
            [[{
                "properties": {
                    "phase": {
                        "enum": ["rewrite", "access", "header_filer", "body_filter", "log", "balancer"],
                        "type": "string"
                    },
                    "functions": {
                        "minItems": 1,
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    }
                },
                "required": ["functions"],
                "type": "object"
            }]]
            )

        ngx.status = code
        ngx.say(body)
    }
}
--- request
GET /t
--- response_body
passed
--- no_error_log
[error]



=== TEST 7: serverless-post-function
--- config
location /t {
    content_by_lua_block {
        local t = require("lib.test_admin").test
        local code, body = t('/apisix/admin/plugins/serverless-post-function',
            ngx.HTTP_GET,
            nil,
            [[{
                "properties": {
                    "phase": {
                        "enum": ["rewrite", "access", "header_filer", "body_filter", "log", "balancer"],
                        "type": "string"
                    },
                    "functions": {
                        "minItems": 1,
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    }
                },
                "required": ["functions"],
                "type": "object"
            }]]
            )

        ngx.status = code
        ngx.say(body)
    }
}
--- request
GET /t
--- response_body
passed
--- no_error_log
[error]



=== TEST 8: get plugin udp-logger schema
--- request
GET /apisix/admin/plugins/udp-logger
--- response_body  eval
qr/{"properties":/
--- no_error_log
[error]



=== TEST 9: get plugin grpc-transcode schema
--- request
GET /apisix/admin/plugins/grpc-transcode
--- response_body eval
qr/"proto_id".*additionalProperties/
--- no_error_log
[error]
