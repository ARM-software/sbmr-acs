# Copyright (c) 2023, Arm Limited or its affiliates. All rights reserved.
# SPDX-License-Identifier : Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

*** Variables ***
# Response codes
${HTTP_CONTINUE}                         100
${HTTP_SWITCHING_PROTOCOLS}              101
${HTTP_PROCESSING}                       102
${HTTP_OK}                               200
${HTTP_CREATED}                          201
${HTTP_ACCEPTED}                         202
${HTTP_NON_AUTHORITATIVE_INFORMATION}    203
${HTTP_NO_CONTENT}                       204
${HTTP_RESET_CONTENT}                    205
${HTTP_PARTIAL_CONTENT}                  206
${HTTP_MULTI_STATUS}                     207
${HTTP_IM_USED}                          226
${HTTP_MULTIPLE_CHOICES}                 300
${HTTP_MOVED_PERMANENTLY}                301
${HTTP_FOUND}                            302
${HTTP_SEE_OTHER}                        303
${HTTP_NOT_MODIFIED}                     304
${HTTP_USE_PROXY}                        305
${HTTP_TEMPORARY_REDIRECT}               307
${HTTP_BAD_REQUEST}                      400
${HTTP_UNAUTHORIZED}                     401
${HTTP_PAYMENT_REQUIRED}                 402
${HTTP_FORBIDDEN}                        403
${HTTP_NOT_FOUND}                        404
${HTTP_METHOD_NOT_ALLOWED}               405
${HTTP_NOT_ACCEPTABLE}                   406
${HTTP_PROXY_AUTHENTICATION_REQUIRED}    407
${HTTP_REQUEST_TIMEOUT}                  408
${HTTP_CONFLICT}                         409
${HTTP_GONE}                             410
${HTTP_LENGTH_REQUIRED}                  411
${HTTP_PRECONDITION_FAILED}              412
${HTTP_REQUEST_ENTITY_TOO_LARGE}         413
${HTTP_REQUEST_URI_TOO_LONG}             414
${HTTP_UNSUPPORTED_MEDIA_TYPE}           415
${HTTP_REQUESTED_RANGE_NOT_SATISFIABLE}  416
${HTTP_EXPECTATION_FAILED}               417
${HTTP_UNPROCESSABLE_ENTITY}             422
${HTTP_LOCKED}                           423
${HTTP_FAILED_DEPENDENCY}                424
${HTTP_UPGRADE_REQUIRED}                 426
${HTTP_INTERNAL_SERVER_ERROR}            500
${HTTP_NOT_IMPLEMENTED}                  501
${HTTP_BAD_GATEWAY}                      502
${HTTP_SERVICE_UNAVAILABLE}              503
${HTTP_GATEWAY_TIMEOUT}                  504
${HTTP_HTTP_VERSION_NOT_SUPPORTED}       505
${HTTP_INSUFFICIENT_STORAGE}             507
${HTTP_NOT_EXTENDED}                     510
