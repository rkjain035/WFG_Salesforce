@isTest(SeeAllData=true)
global class AutocreatedRegHandler1479334445544Test {
    /*static testMethod void validateAutocreatedRegHandler() {
   // StandardUserRegistrationHandler handler = new StandardUserRegistrationHandler();
	      AutocreatedRegHandler1479334445544 handler = new AutocreatedRegHandler1479334445544();

    Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
        null, new Map<String, String>{'language' => 'en_US'});

	Map<String, String> att1 = new Map<String, String>();
    att1.put('Contact.LastName','test');
    att1.put('Contact.FirstName','test2');
    att1.put('Contact.Email','test@test2.com');

	att1.put('User.Email','test@test2.com');
    att1.put('User.Username', 'test@test2.com');
    att1.put('User.PortalRole','WFG_Sales_Representative' );

    att1.put('User.FederationIdentifier', 'test@test2.com');
    att1.put('User.IsActive', '1');
    att1.put('User.FirstName', 'test');
    att1.put('User.CommunityNickname', 'testnic');
    att1.put('User.Alias', 'testali');

		//global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,       String federationIdentifier, Map<String, String> attributes,String assertion)		

	SamlSsoConfig s = new SamlSsoConfig();
    s = [SELECT MasterLabel,id FROM SamlSsoConfig where MasterLabel = 'WFG Self Help'];

    Site si = new Site();
    si = [SELECT Name, id FROM Site Where Name = 'WFG_Support' LIMIT 1];

	//att1.put('User.ProfileId', si.Id);

	User u = handler.createUser(s.Id,si.Id,null,'test@test2.com', att1,'');
    System.assertEquals('test@test2.com', u.userName);

	insert(u);
    String uid = u.id;

    sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
'testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
        null, new Map<String, String>{});
    //handler.updateUser(uid, null, sampleData);
    handler.updateUser(uid,s.Id, si.Id, null,'testuserlong@salesforce.com', sampledata, 'Assertion string');

    User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
    System.assertEquals('testnewuserlong@salesforce.com', updatedUser.userName);
    System.assertEquals('testnewuser@example.org', updatedUser.email);
    System.assertEquals('testNewLast', updatedUser.lastName);
    System.assertEquals('testNewFirst', updatedUser.firstName);
    System.assertEquals('testnewu', updatedUser.alias);

}*/
}