@isTest (SeeAllData=true)
public class KB_articles_test {
	/*	
	 * 	environnement CREATION!!!!!!!!
	 * Creates all types of variables
	 *	 
	 *//*
    public static How_To__kav createHowTo(String articleTitle, String stepbystep, String urlnames, String language, String channel){
        String languageLowerCase = language.toLowerCase();
        String channelLowerCase = channel.toLowerCase();
        How_To__kav article = new How_To__kav();
        if(languageLowerCase == 'pt' || languageLowerCase == 'pt_br' || languageLowerCase == 'portugues'){
            if(channel == 'partner'){
                article = new How_To__kav(Title=articleTitle, Step_By_Step__c=stepbystep, UrlName=urlnames, language='pt_BR', IsVisibleInPrm = true);
            }
            else{
                article = new How_To__kav(Title=articleTitle, Step_By_Step__c=stepbystep, UrlName=urlnames, language='pt_BR', IsVisibleInCsp = true);
            } 
        }
        if(languageLowerCase == 'en' || languageLowerCase == 'ingles' || languageLowerCase == 'english'){
            if(channel == 'partner'){
                article = new How_To__kav(Title=articleTitle, Step_By_Step__c=stepbystep, UrlName=urlnames, language='en_US', IsVisibleInPrm = true);
            }
            else{
                article = new How_To__kav(Title=articleTitle, Step_By_Step__c=stepbystep, UrlName=urlnames, language='en_US', IsVisibleInCsp = true);
            } 
        }
   		
        insert article;
        System.debug(article.Id);

        article = [SELECT Id,KnowledgeArticleId, UrlName, ArticleNumber From How_To__kav WHERE Id=:article.id];
        
        How_To__DataCategorySelection dataCategory = new How_To__DataCategorySelection();
        dataCategory.ParentId = article.ID;
        dataCategory.DataCategoryGroupName = 'Support_Options';
        dataCategory.DataCategoryName = 'Insurance';
        Insert dataCategory;
        System.debug(article.KnowledgeArticleId);
        
        How_To__DataCategorySelection dataCategory2 = new How_To__DataCategorySelection();
        dataCategory2.ParentId = article.ID;
        dataCategory2.DataCategoryGroupName = 'Support_Options';
        dataCategory2.DataCategoryName = 'Applications';     
        Insert dataCategory2;
        
        System.debug(article.KnowledgeArticleId);
        KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

        return [SELECT Id,KnowledgeArticleId, UrlName, ArticleNumber, Title, Step_By_Step__c, language, PublishStatus From How_To__kav WHERE Id=:article.id];
        
    }
    public static Faq__kav createFaq(String articleTitle, String stepbystep, String urlnames, String language, String channel){
        String languageLowerCase = language.toLowerCase();
        String channelLowerCase = channel.toLowerCase();
        Faq__kav article = new Faq__kav();
        if(languageLowerCase == 'pt' || languageLowerCase == 'pt_br' || languageLowerCase == 'portugues'){
            if(channel == 'partner'){
                article = new Faq__kav(Title=articleTitle, Step_By_Step__c=stepbystep, UrlName=urlnames, language='pt_BR', IsVisibleInPrm = true);
            }
            else{
                article = new Faq__kav(Title=articleTitle, Step_By_Step__c=stepbystep, UrlName=urlnames, language='pt_BR', IsVisibleInCsp = true);
            } 
        }
        if(languageLowerCase == 'en' || languageLowerCase == 'ingles' || languageLowerCase == 'english'){
            if(channel == 'partner'){
                article = new Faq__kav(Title=articleTitle, Step_By_Step__c=stepbystep, UrlName=urlnames, language='en_US', IsVisibleInPrm = true);
            }
            else{
                article = new Faq__kav(Title=articleTitle, Step_By_Step__c=stepbystep, UrlName=urlnames, language='en_US', IsVisibleInCsp = true);
            } 
        }
   		
        insert article;
        System.debug(article.Id);

        article = [SELECT Id,KnowledgeArticleId, UrlName, ArticleNumber From Faq__kav WHERE Id=:article.id];
        
        Faq__DataCategorySelection dataCategory = new Faq__DataCategorySelection();
        dataCategory.ParentId = article.ID;
        dataCategory.DataCategoryGroupName = 'Support_Options';
        dataCategory.DataCategoryName = 'Insurance';
        Insert dataCategory;
        System.debug(article.KnowledgeArticleId);
        
        Faq__DataCategorySelection dataCategory2 = new Faq__DataCategorySelection();
        dataCategory2.ParentId = article.ID;
        dataCategory2.DataCategoryGroupName = 'Support_Options';
        dataCategory2.DataCategoryName = 'Applications';     
        Insert dataCategory2;
        
        System.debug(article.KnowledgeArticleId);
        KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

        return [SELECT Id,KnowledgeArticleId, UrlName, ArticleNumber, Title, Step_By_Step__c, language, PublishStatus From Faq__kav WHERE id =:article.id];
        
  
       
    }
    public static Video__kav createVideo(String articleTitle, String stepbystep, String urlnames, String language, String channel){
        String languageLowerCase = language.toLowerCase();
        String channelLowerCase = channel.toLowerCase();
        Video__kav article = new Video__kav();
        if(languageLowerCase == 'pt' || languageLowerCase == 'pt_br' || languageLowerCase == 'portugues'){
            if(channel == 'partner'){
                article = new Video__kav(Title=articleTitle, Step_By_Step__c=stepbystep, UrlName=urlnames, language='pt_BR', IsVisibleInPrm = true);
            }
            else{
                article = new Video__kav(Title=articleTitle, Step_By_Step__c=stepbystep, UrlName=urlnames, language='pt_BR', IsVisibleInCsp = true);
            } 
        }
        if(languageLowerCase == 'en' || languageLowerCase == 'ingles' || languageLowerCase == 'english'){
            if(channel == 'partner'){
                article = new Video__kav(Title=articleTitle, Step_By_Step__c=stepbystep, UrlName=urlnames, language='en_US', IsVisibleInPrm = true);
            }
            else{
                article = new Video__kav(Title=articleTitle, Step_By_Step__c=stepbystep, UrlName=urlnames, language='en_US', IsVisibleInCsp = true);
            } 
        }
   		
        insert article;
        System.debug(article.Id);

        article = [SELECT Id,KnowledgeArticleId, UrlName, ArticleNumber From Video__kav WHERE Id=:article.id];
        
        Video__DataCategorySelection dataCategory = new Video__DataCategorySelection();
        dataCategory.ParentId = article.ID;
        dataCategory.DataCategoryGroupName = 'Support_Options';
        dataCategory.DataCategoryName = 'Insurance';
        Insert dataCategory;
        System.debug(article.KnowledgeArticleId);
        
        Video__DataCategorySelection dataCategory2 = new Video__DataCategorySelection();
        dataCategory2.ParentId = article.ID;
        dataCategory2.DataCategoryGroupName = 'Support_Options';
        dataCategory2.DataCategoryName = 'Applications';     
        Insert dataCategory2;
        
        System.debug(article.KnowledgeArticleId);
        KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

        return [SELECT Id,KnowledgeArticleId, UrlName, ArticleNumber, Title, Step_By_Step__c, language, PublishStatus From Video__kav WHERE id=:article.id];
    }
    
    @isTest
    static void getArticle_test(){
        // Variable creation
        String urlnameHowToPartner ='urlnameqqr';
        String urlnameFaqPartner ='outrourlnameqqr';
        String urlnameVideoPartner ='urlnameqqasdasdasdr';
        
        String urlnameHowToCustomer ='urlnameqqrcust';
        String urlnameFaqCustomer ='outrourlnameqqrcust';
        String urlnameVideoCustomer ='urlnameqqasdasdasdrcust';
        
        How_To__kav articleHowTo = createHowTo('urlnameqqrtitu','era uma vez..', urlnameHowToPartner, 'pt', 'partner');
        Faq__kav articleFaq = createFaq('urlnameqqr','era uma vez..', urlnameFaqPartner, 'pt', 'partner');
        Video__kav articleVideo = createVideo('urlnameqqr','era uma vez..', urlnameVideoPartner, 'pt', 'partner');
        
        How_To__kav articleHowToCustomer = createHowTo('urlnameqqr','era uma vez..', urlnameHowToCustomer, 'en', 'customer');
        Faq__kav articleFaqCustomer = createFaq('urlnameqqr','era uma vez..', urlnameFaqCustomer, 'en', 'customer');
        Video__kav articleVideoCustomer = createVideo('urlnameqqr','era uma vez..', urlnameVideoCustomer, 'en', 'customer');
        
        Test.startTest();
        	String HowToSerializedPartner = KB_articles.getArticle(urlnameHowToPartner ,'partner', 'pt');
        	String faqSerializedPartner = KB_articles.getArticle(urlnameFaqPartner ,'partner', 'pt');
        	String videoSerializedPartner = KB_articles.getArticle(urlnameVideoPartner ,'partner', 'pt');
        
        	String HowToSerializedCustomer = KB_articles.getArticle(urlnameHowToCustomer ,'customer', 'en');
        	String faqSerializedCustomer = KB_articles.getArticle(urlnameFaqCustomer ,'customer', 'en');
        	String videoSerializedCustomer = KB_articles.getArticle(urlnameVideoCustomer ,'customer', 'en');
        Test.stopTest();
        System.debug(articleHowToCustomer);
        System.debug(articleFaqCustomer);
        System.debug(articleVideoCustomer);
        System.debug(articleVideo);
        System.debug(articleFaq);
        System.debug(articleHowTo);
        
        if(HowToSerializedPartner == null || faqSerializedPartner== null || videoSerializedPartner == null || HowToSerializedCustomer == null || faqSerializedCustomer== null || videoSerializedCustomer == null){
            System.assert(false, 'Some of the articles were not found');
        }
        if(articleHowToCustomer == null || articleFaqCustomer== null || articleVideoCustomer == null || articleVideo == null || articleFaq== null || articleHowTo == null){
            System.assert(false, 'the test articles were not sucessfuly created');
        }
        List<Map<string, string>> HowToTest = (List<Map<string, string>>) JSON.deserialize(HowToSerializedPartner, List<Map<string, string>>.class);
        System.debug(HowToTest);
        System.assertEquals(articleHowTo.id, HowToTest[0].get('id'));
        
        List<Map<string, string>> FaqTest = (List<Map<string, string>>) JSON.deserialize(faqSerializedPartner,  List<Map<string, string>>.class);
        System.assertEquals(articleFaq.id, FaqTest[0].get('id'));  
        
        List<Map<string, string>> videoTest = (List<Map<string, string>>) JSON.deserialize(videoSerializedPartner, List<Map<string, string>>.class);
        System.assertEquals(articleVideo.id, videoTest[0].get('id'));  
        //partner articles
        List<Map<string, string>> HowToTestCustomer = (List<Map<string, string>>) JSON.deserialize(HowToSerializedCustomer, List<Map<string, string>>.class);
        System.assertEquals(articleHowToCustomer.id, HowToTestCustomer[0].get('id'));
        
        List<Map<string, string>> FaqTestCustomer = (List<Map<string, string>>) JSON.deserialize(faqSerializedCustomer, List<Map<string, string>>.class);
        System.assertEquals(articleFaqCustomer.id, FaqTestCustomer[0].get('id'));  
        
        List<Map<string, string>> videoTestCustomer = (List<Map<string, string>>) JSON.deserialize(videoSerializedCustomer, List<Map<string, string>>.class);
        System.assertEquals(articleVideoCustomer.id, videoTestCustomer[0].get('id'));  
        
    }
    @isTest
    static void getAllCategories_test(){
        List<String> objType = new List<String>();
        objType.add('KnowledgeArticleVersion');
        List<DescribeDataCategoryGroupResult> describeCategoryResult = Schema.describeDataCategoryGroups(objType);
        List<Map<Object, Object>> categoriesListMap = new List<Map<Object, Object>>();
        
        for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
            DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
            pair1.setSobject('KnowledgeArticleVersion');
            pair1.setDataCategoryGroupName(singleResult.getName());
            
            List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
            pairs.add(pair1);
            
            List<Schema.DescribeDataCategoryGroupStructureResult> results =	Schema.describeDataCategoryGroupStructures(pairs, false);
            integer i = 0;
        	for(Schema.DataCategory dc: results[i].getTopCategories()){
                for(Schema.DataCategory dcChild: dc.getChildCategories()){
                    Map<Object, Object> categoriesMap = new Map<Object, Object>();
                    categoriesMap.put('uniqueName',  dcChild.getName());
                    categoriesMap.put('name',        dcChild.getLabel());
                    categoriesListMap.add(categoriesMap);
                }
            	i++;
        	} 
        }
        Test.startTest();
           String categoriesSerialized = KB_articles.getAllCategories('customer','pt_BR');
        Test.stopTest();
        
        System.assertEquals(JSON.serialize(categoriesListMap, true), categoriesSerialized, 'The categories found do not match the one test');
        
    }
    @isTest
    static void getCategory_test(){
        //get one Category, and then check if the test returns the value
        List<String> objType = new List<String>();
        
        objType.add('KnowledgeArticleVersion');
        
        List<DescribeDataCategoryGroupResult> describeCategoryResult = Schema.describeDataCategoryGroups(objType);
        List<Map<Object, Object>> categoriesListMap = new List<Map<Object, Object>>();
        
        DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
        pair1.setSobject('KnowledgeArticleVersion');
        pair1.setDataCategoryGroupName(describeCategoryResult[0].getName());
            
        List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        pairs.add(pair1);
        
        List<Schema.DescribeDataCategoryGroupStructureResult> results =	Schema.describeDataCategoryGroupStructures(pairs, false);
        List<Schema.DataCategory> dc = results[0].getTopCategories();
        List<Schema.DataCategory> dcChild = dc[0].getChildCategories();
        System.debug(dcChild[0].getName());        
        Test.startTest();
        	String categName = KB_articles.getCategory(dcChild[0].getName(), 'customer', 'pt_BR');
        Test.StopTest();
        if(categName == null){
        	System.assert(false,'No value returned from the getCategory() method in CLientAppController');                 
        }
        System.assertEquals(dcChild[0].getLabel(), categName, 'The value gotten from getCategory: '+categName+' did not match the test value: ' +dcChild[0].getLabel());
    }
    @isTest
    static void getArticlesByCateg_test(){
        //article created with insurance data category
        How_To__kav articleHowTo = createHowTo('urlnameqqrtitu','era uma vez..', 'omeuurl', 'pt', 'partner');
        Faq__kav articleFaq = createFaq('urlnameqqr','era uma vez..', 'omeuoutrourl', 'pt', 'partner');
        Video__kav articleVideo = createVideo('urlnameqqrs','era uma vez..', 'aindaoutrourl', 'pt', 'partner');


        Test.startTest();
        	String ArticlesListMap = KB_articles.getArticlesByCategory('Insurance', 'partner' ,'pt_BR');
        Test.stopTest();
        List<Map<String, String>> allArticlesListMap= (List<Map<String, String>>) JSON.deserialize(ArticlesListMap, List<Map<String, String>>.class);
        boolean foundHowTo = false;
        boolean foundFaq = false;
        boolean foundVideo = false;
        for(Map<String, String> articleMap : allArticlesListMap){
            if(articleMap.get('id') == articleHowTo.id){
				foundHowTo = true;
            } 
            if(articleMap.get('id') == articleFaq.id){
				foundFaq = true;
            }  
            if(articleMap.get('id') == articleVideo.id){
				foundVideo = true;
            }  
        }
        System.assert(foundHowTo, 'the how to with the id:'+articleHowTo.id+'was not found');
        System.assert(foundFaq, 'the faq with the id:'+articleFaq.id+'was not found');
        System.assert(foundVideo, 'the video to with the id:'+articleVideo.id+'was not found');
    }
    
    @isTest
    static void insertVote_test(){
        String articleUrlName = 'urlqualquer';
        How_To__kav article = KB_articles_test.createHowTo('um titulo espectss', '123545 steps', articleUrlName, 'pt', 'partner');
        How_To__ka articleKA = [SELECT ID FROM How_To__ka WHERE ArticleNumber =:article.ArticleNumber];
        
    	Test.startTest();
        	KB_articles.rateArticle(articleUrlName, 'up', 'partner', 'pt');
        Test.stopTest();
        integer numberOfVotes = [SELECT count() FROM Vote WHERE ParentId =:articleKA.ID];
        System.assert(numberOfVotes==1, 'The number of votes did not match the votes associated with the article on ClientAppController_test.rateArticle');
    }
    @isTest
    static void searchArticle_test(){
        
       How_To__kav articleHowTo = KB_articles_test.createHowTo(' adass titulo ', 'asdsadas titulo asdasdas', 'omeuurl', 'pt', 'partner');
       Faq__kav articleFaq = KB_articles_test.createFaq(' adass titulo ', 'asdsadas titulo asdasdas', 'omeuoutrourl', 'pt', 'partner');
       Video__kav articleVideo = KB_articles_test.createVideo(' adass titulo ', 'asdsadas titulo asdasdas', 'aindaoutrourl', 'pt', 'partner');
       Id [] fixedSearchResults= new Id[3];
       fixedSearchResults[0] = articleHowTo.Id;
       fixedSearchResults[1] = articleFaq.Id;
       fixedSearchResults[2] = articleVideo.Id;
       Test.setFixedSearchResults(fixedSearchResults);

        System.debug(articleHowTo);
        Test.startTest();
        	String listSearchedArticles = KB_articles.searchArticle('titulo','partner', 'pt');
            System.debug(listSearchedArticles);
        Test.stopTest();
        if(listSearchedArticles == null){
            System.assert(false, 'the article was not found in ClientAppController_test.searchArticleTest');
        }
        System.debug(listSearchedArticles);
        List<Map<String, String>> articleTest = (List<Map<String, String>>) JSON.deserialize(listSearchedArticles, List<Map<String, String>>.class);
     
        boolean foundHowTo = false;
        boolean foundFaq = false;
        boolean foundVideo = false;
        For(Map<String, String> articleMap : articleTest){
            if(articleMap.get('id')==articleHowTo.id){
                foundHowTo = true;
            }
            if(articleMap.get('id')==articleFaq.id){
                foundFaq = true;
            }
            if(articleMap.get('id')==articleVideo.id){
                foundVideo = true;
            }
        }
        System.assert(foundHowTo,'the how to article HowTo'+articleHowTo.id+'was not found');
        System.assert(foundFaq,'the how to article HowTo'+articleFaq.id+'was not found');
        System.assert(foundVideo,'the how to article HowTo'+articleVideo.id+'was not found');
    }
    @isTest
    static void getAllArticlesOrderedByViews_test(){
    
        List<KnowledgeArticleVersion> articlesOrderedByView = [SELECT ID, articleType,MasterVersionId, Summary, Title, UrlName FROM KnowledgeArticleVersion WHERE (Language='pt_BR' AND isVisibleInPrm = true AND publishStatus='online') ORDER BY ArticleTotalViewCount DESC LIMIT 12];
		
    	Test.startTest();
        	String listSearchedArticles = KB_articles.getAllArticlesOrderedByViews('partner', 'pt');
        
        	System.debug(listSearchedArticles);
            if(listSearchedArticles == null && articlesOrderedByView != null){
                system.assert(false, 'no articles were found');
            }
        Test.stopTest();
       	List<Map<String, String>> kavListMap =  (List<Map<String, String>>) JSON.deserialize(listSearchedArticles, List<Map<String, String>>.class);
        For(integer i = 0; i < kavListMap.size(); i++){
            System.assertEquals(kavListMap[i].get('id'), articlesOrderedByView[i].MasterVersionId, 'The test order is not the expected ');
        }
        
        
    }
    @isTest
    static void getArticlesByType_test(){
        How_To__kav articleHowTo = createHowTo('urlnameqqrtitu','era uma vez..', 'omeuurasdal', 'pt', 'partner');
        
        Faq__kav articleFaq = createFaq('urlnameqqr','era uma vez..', 'omeuoutrourl', 'pt', 'partner');
        Faq__kav articleFaq2 = createFaq('urlnameqqasdasr','era asdasd vez..', 'omeuoutrourlasd', 'pt', 'partner');
        
        Video__kav articleVideo = createVideo('urlnameqqrs','era uma vez..', 'aindaoutrourl', 'pt', 'partner');
        
        test.startTest();
        	String howToArticles  = KB_articles.getArticlesByType('partner', 'pt', 'howto');
        	String faqArticles    = KB_articles.getArticlesByType('partner', 'pt', 'faq');
            String videoArticles  = KB_articles.getArticlesByType('partner', 'pt', 'video');
        test.stopTest();
  
        List<Map<String, String>> howToArticlesTest = (List<Map<String, String>>) JSON.deserialize(howToArticles, List<Map<String, String>>.class);
        System.assertEquals(howToArticlesTest[0].get('id'), articleHowTo.id);
                            
        List<Map<String, String>> videoArticlesTest = (List<Map<String, String>>) JSON.deserialize(videoArticles, List<Map<String, String>>.class);
        System.assertEquals(videoArticlesTest[0].get('id'), articleVideo.id);
       
        List<Map<String, String>> faqArticlesTest = (List<Map<String, String>>) JSON.deserialize(faqArticles, List<Map<String, String>>.class);
      
        System.assert(faqArticlesTest[0].get('id') == articleFaq.id || faqArticlesTest[0].get('id') == articleFaq2.id, 'Faq article 1 was not returned');
        System.assert(faqArticlesTest[1].get('id') == articleFaq.id || faqArticlesTest[1].get('id') == articleFaq2.id, 'Faq article 1 was not returned');
        
    }
    /*@isTest
    static void insertKBSearchTerm_test(){
        RentingApplication_Util_Test ra = new RentingApplication_Util_Test();
        Map<String, String>  infoMap = ra.environment8();
        test.startTest();
        	KB_articles.insertKBSearchTerm(infoMap.get('login'), 'searchtermqqr','customer', 'pt');
        test.stopTest();
        List<KnowledgeBase_Search__c> kbSearch = [SELECT ID from KnowledgeBase_Search__c WHERE Search_Term__c = 'searchtermqqr'];
        System.debug(kbSearch);
        System.assert(kbSearch.size()>0, 'No result found in for the search in the insertKBSearchTerm_test');
        
    }*/
  	
   
}