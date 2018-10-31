public with sharing class DemoController {
    @AuraEnabled
    public static void deleteAll() {
        List<Account> accounts = [SELECT Id FROM Account WHERE Name != 'Website Customers'];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Account.isPersonAccount = false];
        List<Entitlement> entitlements = [SELECT Id FROM Entitlement];
        List<Case> cases = [SELECT Id FROM Case];
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
        List<Vehicle__c> vehicles = [SELECT Id FROM Vehicle__c];
        List<Loan__c> loans = [SELECT Id FROM Loan__c];
        
        delete loans;
        delete vehicles;
        delete cases;
        delete opportunities;
        delete entitlements;
        delete contacts;
        delete accounts;
    }
    
    @AuraEnabled
    public static ID generateAccount() {
        return createAccount();
    }
    
    @AuraEnabled
    public static void generateAccounts() {
        for (Integer i = 0; i < 10; i++) {
            createAccount();
        }
    }
    
    @AuraEnabled
    public static void resetAccount(String recordId) {
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE AccountId = :recordId];
        List<Vehicle__c> vehicles = [SELECT Id FROM Vehicle__c WHERE Owner__r.Account.Id = :recordId];
        delete opportunities;
        delete vehicles;
    }
    
    @AuraEnabled
    public static String GetCurrentUsersFirstName() {
        return UserInfo.getFirstName();
    }
    
    @AuraEnabled
    public static String getCurrentUsersEvaluationVehicleID() {
        String contactId = getContactIDForCurrentUser();
        if (contactId == null) {
            return null;
        }
        Vehicle__c[] vehicles = [SELECT Id FROM Vehicle__c WHERE Owner__c = :contactId AND Status__c = 'Evaluation'];
        if (vehicles.size() > 0) {
            return vehicles[0].Id;
        } else {
            return null;
        }
    }
    
    @AuraEnabled  
    public static String createEvaluationVehicleForCurrentUser(String model) {
        String contactId = getContactIDForCurrentUser();
        if (contactId == null) {
            return null;
        }
        
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Model__c = model;
        vehicle.Owner__c = contactId;
        insert vehicle;
        return vehicle.Id;
    }
    
    @AuraEnabled
    public static String createLoanForUser(String vehicleID, String price, String terms, String downpayment) {
        Contact contact = getContactForCurrentUser();
        Loan__c loan = new Loan__c();
        loan.Price__c = integer.valueof(price);
        loan.Terms__c = integer.valueof(terms);
        loan.Interest__c = 6.00;
        loan.Downpayment__c = integer.valueof(downpayment);
        loan.Status__c = 'Pending';
        loan.Customer__c = contact.Id;
        loan.Vehicle__c = vehicleID;
        loan.FirstName__c = contact.FirstName;
        loan.LastName__c = contact.LastName;
        loan.Employer__c = contact.Employer__c;
        insert loan;
        
        Vehicle__c vehicle = [SELECT Id, Status__c FROM Vehicle__c WHERE Id = :vehicleID LIMIT 1];
        vehicle.Status__c = 'Purchase';
        update vehicle;
        
        return loan.Id;        
    }
    
    // ------------------------------------------------------------------------------------
    
    public static Contact getContactForCurrentUser() {
        String contactId = getContactIDForCurrentUser();
        Contact contact = [SELECT Id, FirstName, LastName, Employer__c FROM Contact WHERE Id = :contactId LIMIT 1];
        return contact;
    }
    
    public static String getContactIDForCurrentUser() {
        User[] users = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if (users.size() > 0) {
            if (users[0].ContactId != null) {
                return users[0].ContactId;
            } else {
                // If we have a User, but no associated Contact...
                Contact[] contacts = [SELECT Id FROM Contact WHERE Username__c = :UserInfo.getUserName() ORDER BY LastModifiedDate DESC];
                if (contacts.size() > 0) {
                    return contacts[0].Id;
                }
            }
        }
        return null;
    }
    
    public static ID createAccount() {
        HTTPResponse response = getRandomUserMe();
        String first, last, street, city, state, postcode, email, username, phone, cell, dob;
        
        JSONParser parser = JSON.createParser(response.getBody());
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String field = parser.getText();
                parser.nextToken();
                if (field == 'first') {
                    first = parser.getText().capitalize();
                } else if (field == 'last') {
                    last = parser.getText().capitalize();
                } else if (field == 'street') {
                    //street = titleCase(parser.getText());
                    street = '5 Wall St';
                } else if (field == 'city') {
                    //NNocity = titleCase(parser.getText());
                    city = 'Burlington';
                } else if (field == 'state') {
                    state = 'MA';
                } else if (field == 'postcode') {
                    //postcode = parser.getText().capitalize();
                    postcode = '01803';
                } else if (field == 'email') {
                    email  = parser.getText();
                } else if (field == 'username') {
                    username = parser.getText();
                } else if (field == 'phone') {
                    phone = parser.getText();
                } else if (field == 'cell') {
                    cell = parser.getText();
                }
            }
        }
        
        Map<String, String> address = randomAddress();
        
        Account account = new Account();
        account.AccountNumber = String.valueOf(randomInt(100000000, 999999999));
        account.Name = first + ' ' + last;
        account.Phone = phone;
        account.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Household'].Id;
        account.BillingStreet = address.get('street');
        account.BillingCity = address.get('city');
        account.BillingState = address.get('tate');
        account.BillingPostalCode = address.get('postcode');
        account.BillingCountry = address.get('country');
        account.ShippingStreet = address.get('street');
        account.ShippingCity = address.get('city');
        account.ShippingState = address.get('state');
        account.ShippingPostalCode = address.get('postcode');
        account.ShippingCountry = address.get('country');
        account.Type = 'Customer';
        //account.Username__c = username;
        insert account;
        
        Contact contact = createContact(account, first, last, email, phone, cell, dob);
        account.Primary_Contact__c = contact.Id;
        update account;
        
        Vehicle__c vehicle = createVehicle(account, contact);
        
        if (vehicle.Status__c == 'Purchase') {
            createLoan(contact, vehicle);
        }
        
        return account.Id;
    }
    
    public static Contact createContact(Account account, String first, String last, String email, String phone, String cell, String dob) {
        Contact contact = new Contact();
        contact.FirstName = first;
        contact.LastName = last;
        contact.Email = email;
        contact.Phone = phone;
        contact.MobilePhone = cell;
        contact.MailingStreet = account.BillingStreet;
        contact.MailingCity = account.BillingCity;
        contact.MailingState = account.BillingState;
        contact.MailingPostalCode = account.BillingPostalCode;
        contact.MailingCountry = account.BillingCountry;
        contact.OtherStreet = account.BillingStreet;
        contact.OtherCity = account.BillingCity;
        contact.OtherState = account.BillingState;
        contact.OtherPostalCode = account.BillingPostalCode;
        contact.OtherCountry = account.BillingCountry;        
        contact.AccountId = account.Id;
        insert contact;
        return Contact;
    }
    
    public static Vehicle__c createVehicle(Account account, Contact contact) {
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Year__c = String.valueOf(System.Today().year());
        vehicle.Status__c = randomString(new string[]{'Evaluation', 'Purchase', 'Manufacturing', 'Delivery', 'Ownership'});
        vehicle.Model__c = randomString(new string[]{'Flint', 'Flare', 'Flash'});
        vehicle.Paint__c = String.valueOf(randomInt(0, 10000));
        vehicle.Wheels__c = randomString(new string[]{'19" Silver Wheels', '19" Sonic Carbon Wheels', '19" Onyx Black Spinners'});
        vehicle.Interior__c = randomString(new string[]{'White Premium', 'Black Premium', 'Light Premium', 'Cream Premium', 'Black Textile'});
        vehicle.Autopilot__c = randomBoolean();
        vehicle.Sunroof__c = randomBoolean();
        vehicle.Rear_Seats__c = randomBoolean();
        vehicle.Hydraulic_System__c = randomBoolean();
        vehicle.Battery__c = randomString(new string[]{'75 kWh', '100 kWh', '100P kWh'});
        vehicle.Owner__c = contact.Id;
        
        /*
        if (vehicle.Status__c == 'Manufacturing' || vehicle.Status__c == 'Delivery' || vehicle.Status__c == 'Ownership') {
            vehicle.SAP_ID__c = randomString(new string[]{'V-00001', 'V-00002', 'V-00003', 'V-00004', 'V-00005'});
        }
		*/
        
        if (vehicle.Status__c == 'Manufacturing') {
            vehicle.Manufacturing_Status__c = randomString(new string[]{'Backlog', 'Stamping', 'Welding', 'Painting', 'Assembly', 'Complete'});
        }
        
        insert vehicle;
        return vehicle;
    }
    
    public static Loan__c createLoan(Contact contact, Vehicle__c vehicle) {
        Loan__c loan = new Loan__c();
        loan.Customer__c = contact.Id;
        loan.Status__c = randomString(new string[]{'Pending', 'Declined', 'Approved', 'Approved'});
        loan.Vehicle__c = vehicle.Id;
        loan.Price__c = randomInt(50000, 160000);
        loan.Terms__c = integer.valueof(randomString(new string[]{'30', '60', '90'}));
        loan.Interest__c = randomInt(2, 10);
        loan.Downpayment__c = randomInt(1, 20) * 1000;
        loan.FirstName__c = contact.FirstName;
        loan.LastName__c = contact.LastName;
        loan.SSN__c = '5555555555';
        insert loan;
        return loan;
    }
    
    public static HttpResponse getRandomUserMe() {
        HttpRequest request = new HttpRequest();                                                     
        request.setEndpoint('https://randomuser.me/api/?nat=us');
        request.setMethod('GET');         
        Http htp = new Http();
        HTTPResponse response = htp.send(request);
        return response;
    }
    
    public static Integer randomInt(Integer lowerLimit, Integer upperLimit){
        Integer rand = Math.round(Math.random() * (upperLimit - lowerLimit)) + lowerLimit;
        return rand;
    }
    
    public static String randomString(string[] Strings) {
        return Strings[randomInt(0, Strings.size()-1)];
    }
    
    public static Boolean randomBoolean() {
        if (randomInt(0,1) == 0) {
            return false;
        } else {
            return true;
        }
    }
    
    public static Map<String, String> randomAddress() {
        List<Map<String, String>> addresses = new List<Map<String, String>>();
        addresses.add(addAddress('950 East Paces Ferry Road NE', 'Atlanta', 'GA', '30326', 'USA'));
        addresses.add(addAddress('929 108th Ave NE', 'Bellevue', 'WA', '98004', 'USA'));
        addresses.add(addAddress('500 Boylston Street', 'Boston', 'MA', '02116', 'USA'));
        addresses.add(addAddress('111 West Illinois Street', 'Chicago', 'IL', '60654', 'USA'));
        addresses.add(addAddress('2550 Wasser Terrace', 'Herndon', 'VA', '20171', 'USA'));
        addresses.add(addAddress('2035 NE Cornelius Pass Road', 'Hillsboro', 'OR', '97124', 'USA'));
        addresses.add(addAddress('111 Monument Circle', 'Indianapolis', 'IN', '46204', 'USA'));
        addresses.add(addAddress('300 Spectrum Center Drive', 'Irvine', 'CA', '92618', 'USA'));
        addresses.add(addAddress('361 Centennial Parkway', 'Louisville', 'CO', '80027', 'USA'));
        addresses.add(addAddress('1095 Avenue of the Americas', 'New York', 'NY', '10036', 'USA'));
        addresses.add(addAddress('1442 2nd Street', 'Santa Monica', 'CA', '90401', 'USA'));
        addresses.add(addAddress('12825 East Mirabeau Parkway', 'Spokane', 'WA', '99216', 'USA'));
        addresses.add(addAddress('4301 West Boy Scout Blvd', 'Tampa', 'FL', '33607', 'USA'));
        addresses.add(addAddress('10 Bay Street', 'Toronto', 'ON', 'M5J 2R8', 'Canada'));
        return addresses[randomInt(0, addresses.size() - 1)];
    }
    
    public static Map<String, String> addAddress(String street, String city, String state, String postcode, String country) {
        return new Map<String, String>{'street' => street, 'city' => city, 'state' => state, 'postcode' => postcode, 'country' => country};
    }
}