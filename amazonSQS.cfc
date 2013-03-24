<cfcomponent output="false" extends="amazonAWS" >
    <cffunction name="init" access="public" returntype="amazonSQS" >
        <cfargument name="awsAccessKeyId" type="string" required="true"/>
        <cfargument name="secretAccessKey" type="string" required="true"/>
        <cfargument name="endPoint" type="string" required="true" default="sqs.us-east-1.amazonaws.com"/>
                
        <cfset variables.awsAccessKeyId = arguments.awsAccessKeyId />
        <cfset variables.secretAccesskey = arguments.secretAccessKey />
        <cfset variables.endPoint = arguments.endPoint />
        <cfset variables.requestMethod = 'no-header' />
        <cfset variables.version = '2011-10-01' />
        <cfreturn this />       
    </cffunction>   
    
    <cffunction name="createQueue" access="public" returntype="Struct" >
        <cfargument name="QueueName" type="string" required="true" >
        
        <cfset var stResponse = createResponse() />
        <cfset var body = "Action=CreateQueue&QueueName=" & trim(arguments.QueueName) />
        
        <cfset var rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version ) />
        
        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        <cfelse>                                
            <cfset stResponse.result = getResultNodes(xmlParse(rawResult.filecontent),'QueueUrl') />
            <cfset stResponse.result = stResponse.result[1] />
        </cfif>
        
        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>
    
    <cffunction name="ListQueues" access="public" returntype="Struct" >
        <cfargument name="QueueNamePrefix" type="string" required="false" default="" >
        
        <cfset var stResponse = createResponse() />
        <cfset var body = "Action=ListQueues" />
        <cfset var rawResult = "" />

        <cfif len(trim(arguments.QueueNamePrefix))>
            <cfset body &= "&QueueNamePrefix=" & trim(arguments.QueueNamePrefix) />
        </cfif>

        <cfset rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version ) />
        
        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        <cfelse>    
            <cfset stResponse.result=[] />
            <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'QueueUrl') />
            
            <cfloop array="#dataResult#" index="item">
                <cfset arrayAppend(stResponse.result,item.xmlText) />
            </cfloop>
        </cfif>     
        
        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>
    
    <cffunction name="GetQueueUrl" access="public" returntype="Struct" >
        <cfargument name="QueueName" type="string" required="true" >
        
        <cfset var stResponse = createResponse() />
        <cfset var body = "Action=GetQueueUrl&QueueName=" & trim(arguments.QueueName) />

        <cfset var rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version ) />
        
        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        <cfelse>                                
            <cfset stResponse.result = getResultNodes(xmlParse(rawResult.filecontent),'QueueUrl') />
            <cfset stResponse.result = stResponse.result[1] />
        </cfif>
            
        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>
    
    <cffunction name="ReceiveMessage" access="public" returntype="Struct" >
        <cfargument name="Queue" type="string" required="true" >
        <cfargument name="MaxNumberOfMessages" type="string" required="false" default="10" >
        <cfargument name="VisibilityTimeout" type="string" required="false" default="30" >
        <cfargument name="AttributeName" type="string" required="false" default="" hint="Valid values: All | SenderId | SentTimestamp | ApproximateReceiveCount | ApproximateFirstReceiveTimestamp" >
        <cfset var stResponse = createResponse() />
        <cfset var body = "Action=ReceiveMessage" />
        <cfset var resultItem = "" />
        <cfset var rawResult = "" />

        <cfif len(trim(arguments.MaxNumberOfMessages))>
            <cfset body &= "&MaxNumberOfMessages=" & trim(arguments.MaxNumberOfMessages) />
        </cfif> 
        <cfif len(trim(arguments.VisibilityTimeout))>
            <cfset body &= "&VisibilityTimeout=" & trim(arguments.VisibilityTimeout) />
        </cfif> 
        <cfif len(trim(arguments.AttributeName))>
            <cfset body &= "&AttributeName=" & trim(arguments.AttributeName) />
        </cfif> 
        
        <cfset rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    uri = replacenocase(arguments.Queue,'http://' & variables.endPoint,'','all'),
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version ) />

        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        <cfelse>    
            <cfset stResponse.result=[]/>
            <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'Message') />
            <cfloop array="#dataResult#" index="result">
                <cfset resultItem = structNew() />
                <cfset resultItem["messageID"] = getValue(result,'messageID') />
                <cfset resultItem["ReceiptHandle"] = getValue(result,'ReceiptHandle') />
                <cfset resultItem["MD5OfBody"] = getValue(result,'MD5OfBody') />
                <cfset resultItem["Body"] = getValue(result,'Body') />
                <cfset arrayAppend(stResponse.result,resultItem) />
            </cfloop>   
        </cfif>
        
        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>
        
    <cffunction name="SetQueueAttributes" access="public" returntype="Struct" >
        <cfargument name="Queue" type="string" required="true" >
        <cfargument name="name" type="string" required="true" >
        <cfargument name="value" type="string" required="true" >
        
        <cfset var stResponse = createResponse() />
        <cfset var body = "Action=SetQueueAttributes&Attribute.Name=" & trim(arguments.name) & '&Attribute.Value=' & trim(arguments.value) />
            
        <cfset var rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    uri = replacenocase(arguments.Queue,'http://' & variables.endPoint,'','all'),
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version ) />
                                    
        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        </cfif>                             

        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>   
    
    <cffunction name="GetQueueAttributes" access="public" returntype="Struct" >
        <cfargument name="Queue" type="string" required="true" >
        <cfargument name="attributes" type="string" required="true" >
        
        <cfset var stResponse = createResponse() />
        <cfset var body = "Action=GetQueueAttributes" />
        <cfset var rawResult = "" />

        <cfloop from="1" to="#listLen(arguments.attributes)#" index="i">
            <cfset body &= "&AttributeName." & i & "=" & trim(listgetat(arguments.attributes,i)) />
        </cfloop>   
        
        <cfset rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    uri = replacenocase(arguments.queue,'http://' & variables.endPoint,'','all'),
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version ) />
        
        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        <cfelse>    
            <cfset stResponse.result={} />
            <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'Attribute') />
            
            <cfloop array="#dataResult#" index="result">
                <cfset stResponse[result.name.xmltext] = getValue(result,'value') />
            </cfloop>   
        </cfif>
        
        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>

    <cffunction name="SendMessage" access="public" returntype="Struct" >
        <cfargument name="Queue" type="string" required="true" >
        <cfargument name="MessageBody" type="string" required="true" >
        <cfargument name="DelaySeconds" type="string" required="false" default="" >
        
        <cfset var stResponse = createResponse() />
        <cfset var body = "Action=SendMessage&MessageBody=" & trim(arguments.MessageBody) />
        <cfset var rawResult = "" />

        <cfif len(trim(arguments.delaySeconds))>
            <cfset body &= "&DelaySeconds=" & arguments.DelaySeconds />
        </cfif>
            
        <cfset rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    uri = replacenocase(arguments.Queue,'http://' & variables.endPoint,'','all'),
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version ) />
        
        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        <cfelse>    
            <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'SendMessageResult') />
            <cfset dataResult = dataResult[1] />
            <cfset stResponse.result= {MD5OfMessageBody=getValue(dataResult,'MD5OfMessageBody'),MessageId=getValue(dataResult,'MessageId')} />
        </cfif>
        
        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>
    
    <cffunction name="SendMessagebatch" access="public" returntype="Struct" >
        <cfargument name="Queue" type="string" required="true" >
        <cfargument name="messages" type="array" required="true" hint="Array of message objects">
        
        <cfset var stResponse = createResponse() />
        <cfset var body = "Action=SendMessageBatch" />
        <cfset var rawResult = "" />
        <cfset var resultItem = "" />

        <cfloop from="1"     to="#arrayLen(arguments.messages)#"    index="i">
            <cfset body &= '&SendMessageBatchRequestEntry.' & i & '.Id=' & trim(arguments.messages[i].id) & 
                            '&SendMessageBatchRequestEntry.' & i & '.MessageBody=' & trim(arguments.messages[i].MessageBody) />
            
            <cfif structKeyExists(arguments.messages[i],'DelaySeconds') && val(arguments.messages[i].DelaySeconds)>
                <cfset body &= '&SendMessageBatchRequestEntry.' & i & '.DelaySeconds=' & trim(arguments.messages[i].DelaySeconds) />
            </cfif> 
        </cfloop>   
        
        <cfset rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    uri = replacenocase(arguments.Queue,'http://' & variables.endPoint,'','all'),
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version ) />
        
        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        <cfelse>    
            <cfset stResponse.result=[] />
            <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'SendMessageBatchResultEntry') />
            
            <cfloop array="#dataResult#" index="result">
                <cfset resultItem["id"] =getValue(result,'id') />
                <cfset resultItem["MessageId"] =getValue(result,'MessageId') />
                <cfset resultItem["MD5OfMessageBody"] =getValue(result,'MD5OfMessageBody') />
                <cfset arrayAppend(stResponse.result,resultItem) />
            </cfloop>   
        </cfif>
        
        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>
    
    <cffunction name="DeleteMessage" access="public" returntype="Struct" >
        <cfargument name="Queue" type="string" required="true" >
        <cfargument name="ReceiptHandle" type="string" required="true" >
        
        <cfset var stResponse = createResponse() />
        <cfset var body = "Action=DeleteMessage&ReceiptHandle=" & trim(arguments.ReceiptHandle) />
        
        <cfset var rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    uri = replacenocase(arguments.Queue,'http://' & variables.endPoint,'','all'),
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version ) />
                                    
        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        <cfelse>    
            <cfdump var="#rawResult#" /><cfabort>
        </cfif> 
        
        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>
    
    <cffunction name="DeleteMessageBatch" access="public" returntype="Struct" >
        <cfargument name="Queue" type="string" required="true" >
        <cfargument name="messages" type="Array" required="true" >
        
        <cfset var stResponse = createResponse() />
        <cfset var body = "Action=DeleteMessageBatch" />
        <cfset var rawResult = "" />

        <cfloop from="1" to="#arrayLen(arguments.messages)#" index="i">
            <cfset body &= "&DeleteMessageBatchRequestEntry." & i & ".Id=" & trim(arguments.messages[i].id) & "&DeleteMessageBatchRequestEntry." & i & ".ReceiptHandle=" & trim(arguments.messages[i].ReceiptHandle) />
        </cfloop>   
        <cfset rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    uri = replacenocase(arguments.Queue,'http://' & variables.endPoint,'','all'),
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version ) />
                                    
        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        <cfelse>                                
            <cfdump var="#rawResult#" /><cfabort>
        </cfif>

        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>
    
    <cffunction name="DeleteQueue" access="public" returntype="Struct" >
        <cfargument name="Queue" type="string" required="true" >
        
        <cfset var stResponse = createResponse() />
        <cfset var body = "Action=DeleteQueue" />
        
        <cfset var rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    uri = replacenocase(arguments.Queue,'http://' & variables.endPoint,'','all'),
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version ) />
                                    
        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        </cfif>
            
        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>
    
    <cffunction name="ChangeMessageVisibility" access="public" returntype="Struct" >
        <cfargument name="Queue" type="string" required="true" >
        <cfargument name="ReceiptHandle" type="string" required="true" >
        <cfargument name="VisibilityTimeout" type="string" required="true" >
        
        <cfset var stResponse = createResponse() /> 
        <cfset var body = "Action=ChangeMessageVisibility&ReceiptHandle=" & trim(arguments.ReceiptHandle) & "&VisibilityTimeout=" & trim(arguments.VisibilityTimeout) />
        
        <cfset var rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    uri = replacenocase(arguments.Queue,'http://' & variables.endPoint,'','all'),
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version,
                                    skipEncryption='ReceiptHandle' ) />
        
        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        <cfelse>                                
            <cfdump var="#rawResult#" /><cfabort>
        </cfif>
        
        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>
    
    <cffunction name="ChangeMessageVisibilityBatch" access="public" returntype="Struct" >
        <cfargument name="Queue" type="string" required="true" >
        <cfargument name="messages" type="array" required="true" >
            
        <cfset var stResponse = createResponse() /> 
        <cfset var body = "Action=ChangeMessageVisibilityBatch" />
        <cfset var rawResult = "" />

        <cfloop from="1" to="#arrayLen(arguments.messages)#" index="i">
            <cfset body &= "&DeleteMessageBatchRequestEntry." & i & ".Id=" & trim(arguments.messages[i].id) & "&DeleteMessageBatchRequestEntry." & i & ".ReceiptHandle=" & trim(arguments.messages[i].ReceiptHandle) />
        </cfloop>   
        
        <cfset rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    uri = replacenocase(arguments.Queue,'http://' & variables.endPoint,'','all'),
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version ) />
        
        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        <cfelse>    
            <cfdump var="#rawResult#" /><cfabort>
        </cfif> 
        
        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>
    
    <cffunction name="AddPermission" access="public" returntype="Struct" >
        <cfargument name="Queue" type="string" required="true" >
        <cfargument name="Label" type="string" required="true" >
        <cfargument name="users" type="array" required="true" >
        
        <cfset var stResponse = createResponse() />     
        <cfset var body = "Action=AddPermission&Label=" & trim(arguments.label) />
        <cfset var rawResult = "" />

        <cfloop from="1" to="#arrayLen(arguments.users)#" index="i">
            <cfset body &= '&AWSAccountId.' & i & '=' & trim(replacenocase(arguments.users[i].AWSAccountId,'-','','all')) & '&ActionName.' & i & '=' & trim(arguments.users[i].actionName) />
        </cfloop>
        
        <cfset rawResult = makeRequestFull(
                                    endPoint = variables.endPoint,
                                    uri = replacenocase(arguments.Queue,'http://' & variables.endPoint,'','all'),
                                    awsAccessKeyId = variables.awsAccessKeyId, 
                                    secretAccesskey = variables.secretAccesskey, 
                                    body=body,
                                    requestMethod = variables.requestMethod,
                                    version = variables.version ) />
                                    
        <cfif rawResult.statusCode neq 200>
            <cfset error = getResultNodes(xmlParse(rawResult.fileContent),'Error') />
            <cfset error = error[1] />
            <cfset stResponse.success=false />
            <cfset stResponse.statusCode=rawResult.statusCode />
            <cfset stResponse.error=error.Code.xmlText/>
            <cfset stResponse.errorType=error.Type.xmlText/>
            <cfset stResponse.errorMessage=error.Message.xmlText/>
        <cfelse>    
            <cfdump var="#xmlParse(rawResult.filecontent)#" /><cfabort>
        </cfif>
        
        <cfset dataResult = getResultNodes(xmlParse(rawResult.filecontent),'RequestId') />
        <cfloop array="#dataResult#" index="item">
            <cfif not len( stResponse.requestID ) >
                <cfset stResponse.requestID = item.xmlText />
            </cfif>
        </cfloop>
        
        <cfreturn stResponse />
    </cffunction>
    
    <cffunction name="getBlankMessage" access="public" returntype="Struct">
        <cfset var resultItem = structNew() />
        <cfset resultItem["Id"] = '' />
        <cfset resultItem["MessageBody"] = '' />
        <cfset resultItem["DelaySeconds"] = '' />
        <cfreturn resultItem />
    </cffunction>   
</cfcomponent>