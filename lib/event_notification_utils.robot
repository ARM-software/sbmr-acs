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

*** Settings ***

Documentation    Resource file for event notification subscription.

*** Keywords ***

Delete All Event Subscriptions
    [Documentation]  Delete all event subscriptions.

    ${subscriptions}=  Redfish.Get Attribute  /redfish/v1/EventService/Subscriptions  Members
    Return From Keyword If  ${subscriptions} is None
    FOR  ${subscription}  IN  @{subscriptions}
        Redfish.Delete  ${subscription['@odata.id']}
    END

Get Event Subscription IDs
    [Documentation]  Get event subscription IDs.

    ${subscription_ids}=  Create List
    ${subscriptions}=  Redfish.Get Attribute  /redfish/v1/EventService/Subscriptions  Members
    Log  ${subscriptions}
    FOR  ${subscription}  IN  @{subscriptions}
        Append To List  ${subscription_ids}
        ...  ${subscription['@odata.id'].split("/redfish/v1/EventService/Subscriptions/")[-1]}
    END
    RETURN  ${subscription_ids}

