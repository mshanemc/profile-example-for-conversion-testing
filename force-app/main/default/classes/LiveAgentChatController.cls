public with sharing class LiveAgentChatController {
    
    public String liveChatBtnId{get; set;}    
    
    public String liveChatDepId{get; set;}
    
    public String liveAgentUserEmail {get; set;}
    public String liveAgentUserName {get; set;}
    
    public LiveAgentChatController(){
    
        LiveChatButton lCBId = [SELECT Id FROM LiveChatButton WHERE DeveloperName = 'Communities_Button'];
        
        Datetime tempDate = datetime.newInstance(0000, 00, 0, 00, 00, 0);
        String latestId;
                
        List<LiveChatDeployment> lDIds = [SELECT Id, CreatedDate FROM LiveChatDeployment];
        
        for (LiveChatDeployment d : lDids){
            if (d.CreatedDate > tempDate){
                latestId = d.Id;
            }    
        }
        
        liveChatBtnId = String.valueOf(lCBId.id); 
        liveChatDepId = latestId;
        
        liveAgentUserEmail = String.valueOf(UserInfo.getUserEmail());
        liveAgentUserName = String.valueOf(UserInfo.getName());     
        
    }
}