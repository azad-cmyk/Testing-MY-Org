public class ProjectTaskHandler {

    public static void updatehandler(Map<Id,Project_Task__c> newProjectMap,Map<Id,Project_Task__c> oldProjectMap){
         Set<Id> projectTaskIdSet =new set<Id>();
        for(Project_Task__c pt:newProjectMap.values()){
            Project_Task__c oldProjectTask=oldProjectMap.get(pt.Id);
            if(  pt.ProjectId__c!=oldProjectTask.ProjectId__c){
                projectTaskIdSet.add(pt.ProjectId__c);
                projectTaskIdSet.add(oldProjectTask.ProjectId__c);
            }
        }
        //find all Project_Task__c  related to Project__c 
        List<AggregateResult> completedAllProjectTask=[select count(id) totalprojectTask,ProjectId__c from Project_Task__c
                                                      where status__c='Completed' group by ProjectId__c];
        system.debug('completedAllProjectTask'+completedAllProjectTask);
        
         List<Project__c> updateProject=new List<Project__c>();
         for(AggregateResult rs:completedAllProjectTask){
            Id pId=(Id) rs.get('ProjectId__c');
            Decimal total=(Decimal) rs.get('totalprojectTask');
            Project__c p=new Project__c(id=pId,Complete_Task_count__c =total );
            updateProject.add(p);
             //removed process Project
             projectTaskIdSet.remove(pId);
        }
        //handle project which has 0 project task
        for(Id pId: projectTaskIdSet){
            Project__c p=new Project__c(id=pId,Complete_Task_count__c =0);  
            updateProject.add(p);
        }
        
         if(!updateProject.isEmpty()){
            try {
            update updateProject;
        } catch (DmlException e) {
            System.debug('Update failed: ' + e.getMessage());
        }
        }
    }
    
    public static void deleteHandler(List<Project_Task__c> oldProjectList){
         Set<Id> projectTaskIdSet =new set<Id>();
        for(Project_Task__c pt:oldProjectList){
            if(pt.ProjectId__c !=null){
                projectTaskIdSet.add(pt.ProjectId__c);
            }
        }
        //find all Project_Task__c  related to Project__c 
        List<AggregateResult> completedAllProjectTask=[select count(id) totalprojectTask,ProjectId__c from Project_Task__c
                                                      where status__c='Completed' group by ProjectId__c];
        system.debug('completedAllProjectTask'+completedAllProjectTask);
        
         List<Project__c> updateProject=new List<Project__c>();
         for(AggregateResult rs:completedAllProjectTask){
            Id pId=(Id) rs.get('ProjectId__c');
            Decimal total=(Decimal) rs.get('totalprojectTask');
            Project__c p=new Project__c(id=pId,Complete_Task_count__c =total );
            updateProject.add(p);
             //removed process Project
             projectTaskIdSet.remove(pId);
        }
        //handle project which has 0 project task
        for(Id pId: projectTaskIdSet){
            Project__c p=new Project__c(id=pId,Complete_Task_count__c =0);  
            updateProject.add(p);
        }
        
         if(!updateProject.isEmpty()){
            try {
            update updateProject;
        } catch (DmlException e) {
            System.debug('Update failed: ' + e.getMessage());
        }
        }
    }
    
    public static void insertHandler(List<Project_Task__c> newProjectlist){
        Set<Id> projectTaskIdSet =new set<Id>();
        for(Project_Task__c pt:newProjectlist){
            if(pt.ProjectId__c !=null){
                projectTaskIdSet.add(pt.ProjectId__c);
            }
        }
        //find all Project_Task__c  related to Project__c 
        List<AggregateResult> completedAllProjectTask=[select count(id) totalprojectTask,ProjectId__c from Project_Task__c
                                                      where status__c='Completed' group by ProjectId__c];
        system.debug('completedAllProjectTask'+completedAllProjectTask);
        
        List<Project__c> updateProject=new List<Project__c>();
        for(AggregateResult rs:completedAllProjectTask){
            Id pId=(Id) rs.get('ProjectId__c');
            Decimal total=(Decimal) rs.get('totalprojectTask');
            Project__c p=new Project__c(id=pId,Complete_Task_count__c =total );
            updateProject.add(p);
        }
        system.debug('updateProject'+updateProject);
        if(!updateProject.isEmpty()){
            update updateProject;
        }
    }
}