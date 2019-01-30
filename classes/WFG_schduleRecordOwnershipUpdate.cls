global class WFG_schduleRecordOwnershipUpdate implements Schedulable {

   global void execute(SchedulableContext ctx) 
   {
      WFG_OwnershipUpdate.UpdateOwners();
   }   
}