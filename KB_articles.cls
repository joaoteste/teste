public class KB_articles {
 	/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>ARTICLE<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
	 /* !!!!!!!!!!!!!!!!!!!!IN CASE OF ADDED Languages CHANGE THIS FUNCTION!!!!!!!!!!!!!!!!!!!!!!

	/*
    private static list<How_To__kav> getIDsHowTosWithLanguageAndChannel(String language, String channel){
        string languageLowerCase = language.toLowerCase();
        string channelLowerCase = channel.toLowerCase();
        //IsVisibleInCsp - visible to customer; IsVisibleInPrm - visible to partner
        if(channel == 'partner' || channel == 'customer'){
            if(language == 'pt' || language =='portugues' || language =='pt_br' || language =='portuguese'){
                if(channel == 'partner'){
                    return [SELECT ID, UrlName, Title, Step_By_Step__c, (SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Summary FROM How_To__kav WHERE PublishStatus='Online' AND Language ='pt_BR' AND IsVisibleInPrm = true];
                }
                else{
                    return [SELECT ID, UrlName, Title, Step_By_Step__c, (SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Summary FROM How_To__kav WHERE PublishStatus='Online' AND Language ='pt_BR' AND IsVisibleInCsp = true];
                }
            }
            if(language == 'ingles' || language =='english' || language =='en'){
                if(channel == 'partner'){
                    return [SELECT ID, UrlName, Title, Step_By_Step__c, (SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Summary FROM How_To__kav WHERE PublishStatus='Online' AND Language ='en_US' AND IsVisibleInPrm = true];
                }
                else{
                    return [SELECT ID, UrlName, Title, Step_By_Step__c, (SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Summary FROM How_To__kav WHERE PublishStatus='Online' AND Language ='en_US' AND IsVisibleInCsp = true];
                }
            }
            
            return null;
        }
        System.debug('invalid type of channel');
        return null;
    }
    /*
	/******************************getHowToWithDataCategory***************************
	 * !!!!!!!!!!!!!!!!!!!!IN CASE OF ADDED DATA CATEGORYS CHANGE THIS FUNCTION!!!!!!!!!!!!!!!!!!!!!!
	**//*
    private static List<How_To__kav> getHowTosWithDataCategory(List<How_To__kav> articleWithLanguageChannel, String dataCategory){
        String dataCategoryLowerCase = dataCategory.toLowerCase();
        List<How_To__kav> howToArticle;
        if(dataCategoryLowerCase == 'digital_signature'){
            return howToArticle = [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName, Summary FROM How_To__Kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Digital_Signature__c];
		}
        if(dataCategoryLowerCase == 'applications'){
            return howToArticle = [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName, Summary FROM How_To__Kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Applications__c];
        }
        if(dataCategoryLowerCase == 'contract_and_auto'){
            return howToArticle = [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName, Summary FROM How_To__Kav WHERE PublishStatus='online' AND Language='pt_BR' WITH DATA CATEGORY Support_Options__c ABOVE Contract_and_Auto__c];
        }
        if(dataCategoryLowerCase == 'invoicing'){
            return howToArticle = [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName, Summary FROM How_To__Kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Invoicing__c];
        }
        if(dataCategoryLowerCase == 'manage_account'){
            return howToArticle = [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName, Summary FROM How_To__Kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Manage_Account__c];
        }
        if(dataCategoryLowerCase == 'insurance'){
            return howToArticle = [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName, Summary FROM How_To__Kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Insurance__c];
        }
    	return null;
    }
    private static List<Map<String, String>> transformHowTosListToListMap(List<How_To__kav> howToList, String channel, String language){
        List<Map<String, String>> howToListMap = new List<Map<String, String>>();
        for(How_To__kav howToArticle: howToList){
            Map<String,String> howToMap = new Map<String, String>();
            howToMap.put('id',                    howToArticle.Id);
            howToMap.put('urlName',               howToArticle.UrlName);
            howToMap.put('channel',               channel);
            howToMap.put('language',              language);
            howToMap.put('title',                 howToArticle.Title);
            howToMap.put('summary',               howToArticle.summary);
            howToMap.put('body',                  howToArticle.Step_by_Step__c);
            if(!howToArticle.DataCategorySelections.isEmpty()){
                if(howToArticle.DataCategorySelections[0] != null){
                    howToMap.put('categoryName',          howToArticle.DataCategorySelections[0].DataCategoryName); 
                }else{
                    howToMap.put('categoryName',   'none'); 
                }
            }
            howToMap.put('articleType',          'HowTo');
            howToListMap.add(howToMap);
        }
        return howToListMap;
    }
    /*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>FAQ<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
    /******************************getIDsOfFaqsWithLanguageAndChannel***************************
	 * !!!!!!!!!!!!!!!!!!!!IN CASE OF ADDED Languages CHANGE THIS FUNCTION!!!!!!!!!!!!!!!!!!!!!!
	/*
    private static list<Faq__kav> getIDsFaqsWithLanguageAndChannel(String language, String channel){
        string languageLowerCase = language.toLowerCase();
        string channelLowerCase = channel.toLowerCase();
        //IsVisibleInCsp - visible to customer; IsVisibleInPrm - visible to partner
        if(channel == 'partner' || channel == 'customer'){
            if(language == 'pt' || language =='portugues' || language =='pt_br' || language =='portuguese'){
                if(channel == 'partner'){
                    return [SELECT ID, UrlName, Title, Step_By_Step__c, summary, (SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections) FROM Faq__kav WHERE PublishStatus='Online' AND Language ='pt_BR' AND IsVisibleInPrm = true];
                }
                else{
                    return [SELECT ID, UrlName, Title, Step_By_Step__c, summary,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections) FROM Faq__kav WHERE PublishStatus='Online' AND Language ='pt_BR' AND IsVisibleInCsp = true];
                }
            }
            if(language == 'ingles' || language =='english' || language =='en'){
                if(channel == 'partner'){
                    return [SELECT ID, UrlName, Title, Step_By_Step__c, summary,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections) FROM Faq__kav WHERE PublishStatus='Online' AND Language ='en_US' AND IsVisibleInPrm = true];
                }
                else{
                    return [SELECT ID, UrlName, Title, Step_By_Step__c, summary,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections) FROM Faq__kav WHERE PublishStatus='Online' AND Language ='en_US' AND IsVisibleInCsp = true];
                }
            }
            
        }
        
        System.debug('invalid type of channel');
        return null;
    }
    /*
	/******************************getFaqsWithDataCategory***************************
	 * !!!!!!!!!!!!!!!!!!!!IN CASE OF ADDED DATA CATEGORYS CHANGE THIS FUNCTION!!!!!!!!!!!!!!!!!!!!!!
	/*
    private static List<Faq__kav> getFaqsWithDataCategory(List<Faq__kav> articleWithLanguageChannel, String dataCategory){
        String dataCategoryLowerCase = dataCategory.toLowerCase();
        List<Faq__kav> faqsArticle;
        if(dataCategoryLowerCase == 'digital_signature'){
            return [SELECT Id, Title, Step_by_Step__c, summary,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName FROM Faq__kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Digital_Signature__c];
		}
        if(dataCategoryLowerCase == 'applications'){
            return [SELECT Id, Title, Step_by_Step__c, summary,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName FROM Faq__kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Applications__c];
        }
        if(dataCategoryLowerCase == 'contract_and_auto'){
            return [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName, Summary FROM Faq__kav WHERE PublishStatus='online' AND Language='pt_BR' WITH DATA CATEGORY Support_Options__c ABOVE Contract_and_Auto__c];
        }
        if(dataCategoryLowerCase == 'invoicing'){
            return [SELECT Id, Title, Step_by_Step__c, summary,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName FROM Faq__kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Invoicing__c];
        }
        if(dataCategoryLowerCase == 'manage_account'){
            return [SELECT Id, Title, Step_by_Step__c, summary,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName FROM Faq__kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Manage_Account__c];
        }
        if(dataCategoryLowerCase == 'insurance'){
            return [SELECT Id, Title, Step_by_Step__c, summary,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName FROM Faq__kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c AT Insurance__c];
        }
    	return null;
    }
    private static List<Map<String, String>> transformFaqsListToListMap(List<Faq__kav> faqList, String channel, String language){
        List<Map<String, String>> faqListMap = new List<Map<String, String>>();
        for(Faq__kav faqArticle: faqList){
            Map<String,String> faqMap = new Map<String, String>();
            faqMap.put('id',                    faqArticle.Id);
            faqMap.put('urlName',               faqArticle.UrlName);
            faqMap.put('channel',               channel);
            faqMap.put('language',              language);
            faqMap.put('title',                 faqArticle.Title);
            faqMap.put('summary',               faqArticle.summary);
            faqMap.put('body',                  faqArticle.Step_by_Step__c);
            if(!faqArticle.DataCategorySelections.isEmpty()){
            	if(faqArticle.DataCategorySelections[0].DataCategoryName != null){
                    faqMap.put('categoryName',          faqArticle.DataCategorySelections[0].DataCategoryName); 
                }else{
                    faqMap.put('categoryName',   'none'); 
                }
            }
            faqMap.put('articleType',          'faq');
            faqListMap.add(faqMap);
        }
        return faqListMap;
    }
    
    /*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>VIDEOS<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
    /******************************getIDsOfVideoWithLanguageAndChannel***************************
	 * !!!!!!!!!!!!!!!!!!!!IN CASE OF ADDED Languages CHANGE THIS FUNCTION!!!!!!!!!!!!!!!!!!!!!!
	
   private static list<Video__kav> getIDsVideosWithLanguageAndChannel(String language, String channel){
        string languageLowerCase = language.toLowerCase();
        string channelLowerCase = channel.toLowerCase();
        //IsVisibleInCsp - visible to customer; IsVisibleInPrm - visible to partner
        if(channel == 'partner' || channel == 'customer'){
            if(language == 'pt' || language =='portugues' || language =='pt_br' || language =='portuguese'){
                if(channel == 'partner'){
                    return [SELECT ID, UrlName, Title, Step_By_Step__c, (SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Summary FROM Video__kav WHERE PublishStatus='Online' AND Language ='pt_BR' AND IsVisibleInPrm = true];
                }
                else{
                    return [SELECT ID, UrlName, Title, Step_By_Step__c, (SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Summary FROM Video__kav WHERE PublishStatus='Online' AND Language ='pt_BR' AND IsVisibleInCsp = true];
                }
            }
            if(language == 'ingles' || language =='english' || language =='en'){
                if(channel == 'partner'){
                    return [SELECT ID, UrlName, Title, Step_By_Step__c, (SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Summary FROM Video__kav WHERE PublishStatus='Online' AND Language ='en_US' AND IsVisibleInPrm = true];
                }
                else{
                    return [SELECT ID, UrlName, Title, Step_By_Step__c, (SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Summary FROM Video__kav WHERE PublishStatus='Online' AND Language ='en_US' AND IsVisibleInCsp = true];
                }
            }
            
        }
        System.debug('invalid type of channel');
        return null;
    }
    /*
	/******************************getVideoWithDataCategory***************************
	 * !!!!!!!!!!!!!!!!!!!!IN CASE OF ADDED DATA CATEGORYS CHANGE THIS FUNCTION!!!!!!!!!!!!!!!!!!!!!!

    private static List<Video__kav> getVideosWithDataCategory(List<Video__kav> articleWithLanguageChannel, String dataCategory){
        String dataCategoryLowerCase = dataCategory.toLowerCase();
        List<Video__kav> howToArticle;
        if(dataCategoryLowerCase == 'digital_signature'){
            return [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName, Summary FROM Video__kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Digital_Signature__c];
		}
        if(dataCategoryLowerCase == 'applications'){
            return [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName, Summary FROM Video__kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Applications__c];
        }
        
         if(dataCategoryLowerCase == 'contract_and_auto'){
            return [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName, Summary FROM Video__kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Contract_and_Auto__c];
        }
        if(dataCategoryLowerCase == 'invoicing'){
            return [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName, Summary FROM Video__kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Invoicing__c];
        }
        if(dataCategoryLowerCase == 'manage_account'){
            return [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName, Summary FROM Video__kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Manage_Account__c];
        }
        if(dataCategoryLowerCase == 'insurance'){
            return [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), Language, UrlName, Summary FROM Video__kav WHERE (ID in:articleWithLanguageChannel) WITH DATA CATEGORY Support_Options__c ABOVE Insurance__c];
        }
    	return null;
    }
    private static List<Map<String, String>> transformVideosListToListMap(List<Video__kav> videoList, String channel, String language){
        List<Map<String, String>> videoListMap = new List<Map<String, String>>();
        for(Video__kav videoArticle: videoList){
            Map<String,String> videoMap = new Map<String, String>();
            videoMap.put('id',                    videoArticle.Id);
            videoMap.put('urlName',               videoArticle.UrlName);
            videoMap.put('channel',               channel);
            videoMap.put('language',              language);
            videoMap.put('title',                 videoArticle.Title);
            videoMap.put('summary',               videoArticle.summary);
            videoMap.put('body',                  videoArticle.Step_by_Step__c);
            if(!videoArticle.DataCategorySelections.isEmpty()){
            	if(videoArticle.DataCategorySelections[0].DataCategoryName != null){
                   videoMap.put('categoryName',   videoArticle.DataCategorySelections[0].DataCategoryName); 
                }
                else{
                    videoMap.put('categoryName',   'none'); 
                }
            }
            videoMap.put('articleType',          'video');
            videoListMap.add(videoMap);
        }
        return videoListMap;
    }
    
    /***************FUNCTIONS AVAILABLE FOR THE CONTROLLER*************************************/
    /*******************************getArticles************************************
		@Return: A serialize list containing maps, keys =>'id', 'urlname', 'channel', 'language', 'title','summary', 'body', 'categoryName' and 'articleType' 
		of the article with the urlname passed as parameter
       
   
	public static String getArticle(String urlName, String channel, String language){
        String visitbleTo;
  	
		list<How_To__kav> languageHowToPickerArticles = getIDsHowTosWithLanguageAndChannel(language, channel);
        if(languageHowToPickerArticles!=null){
            System.debug('How to Kav Found');
            List<How_to__kav> articleHowToList =[SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), UrlName, Summary FROM How_to__kav WHERE (ID in:languageHowToPickerArticles AND UrlName =:urlName)];
            if(!articleHowToList.isEmpty()){
                List<Map<String, String>> returnHowToListMap = transformHowTosListToListMap(articleHowToList, channel, language);
                return JSON.serialize(returnHowToListMap, true);
            }
        }
        
        list<Faq__kav> languageFaqPickerArticles = getIDsFaqsWithLanguageAndChannel(language, channel);
        if(languageFaqPickerArticles!=null){
            System.debug('How to Kav Found');
            List<Faq__kav> articleFaqList =[SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), UrlName, Summary FROM Faq__kav WHERE (ID in:languageFaqPickerArticles AND UrlName =:urlName)];
            if(!articleFaqList.isEmpty()){
                List<Map<String, String>> returnFaqListMap = transformFaqsListToListMap(articleFaqList, channel, language);
                return JSON.serialize(returnFaqListMap, true);
            }
        }
       
        list<Video__kav> languageVideoPickerArticles = getIDsVideosWithLanguageAndChannel(language, channel);
        if(languageVideoPickerArticles!=null){
            System.debug('How to Kav Found');
            List<Video__kav> articleVideoList =[SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), UrlName, Summary FROM Video__kav WHERE (ID in:languageVideoPickerArticles AND UrlName =:urlName)];
            if(!articleVideoList.isEmpty()){
                List<Map<String, String>> returnVideoListMap = transformVideosListToListMap(articleVideoList, channel, language);
                return JSON.serialize(returnVideoListMap, true);
            }
        }

        

        return null;

    }
   
    /*******************************getAllCategories************************************
        @Return: A serialize list containing maps, keys => 'uniquename', 'name' 

	public static String getAllCategories(String channel, String language){
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
        /* DEBUG
        System.debug(categoriesListMap[0].get('uniqueName'));
        System.debug(categoriesListMap[1].get('uniqueName'));
        System.debug(categoriesListMap[2].get('uniqueName'));
	
        return JSON.serialize(categoriesListMap, True);
    }
    
   
    /*******************************getCategory************************************
        @Return: A map  keys => 'uniquename', 'name' 
   
	public static String getCategory(String uniqueName, String channel, String language){
        String categoriesString = ClientAppController.getAllCategories(channel, language);
        List<Map<String,String>> categoriesListMap = (List<Map<String,String>>) JSON.deserialize(categoriesString, List<Map<String,String>>.class);
        for(Map<String,String> categMap : categoriesListMap){
            if(categMap.get('uniqueName') == uniqueName){
                System.debug(categMap.get('name'));
                return categMap.get('name');    
            }
            	
        }
        return null;
    }
    /*******************************getArticlesByCategory************************************
     	@Return: A serialize list containing maps, keys =>'id', 'urlname', 'channel', 'language', 'title','summary', 'body', 'categoryName' and 'articleType' 
		of the article with the urlname passed as parameter
 

	public static String getArticlesByCategory(String uniqueName, String channel, String language){
        List<How_To__kav> howToArticle = new List<How_To__kav>();
        List<Map<String, String>> articlesListMap = new List<Map<String, String>>();
        
        List<Map<String, String>> HowToListMap = new List<Map<String, String>>();
        List<Map<String, String>> FaqListMap = new List<Map<String, String>>();
        List<Map<String, String>> VideoListMap = new List<Map<String, String>>();
        
        
		list<How_To__kav> languagePickerArticles = getIDsHowTosWithLanguageAndChannel(language, channel);
        if(languagePickerArticles != null && languagePickerArticles.size() > 0){
            List<How_To__kav> HowTolist = getHowTosWithDataCategory(languagePickerArticles, uniqueName);
            if(HowTolist != null && HowTolist.size() > 0){
                HowToListMap = transformHowTosListToListMap(HowTolist, channel, language);               
            }
        }
       
        list<Faq__kav> languagePickerFaq = getIDsFaqsWithLanguageAndChannel(language, channel);
        if(languagePickerFaq != null && languagePickerFaq.size() > 0){
            List<Faq__kav> faqlist = getFaqsWithDataCategory(languagePickerFaq, uniqueName);
            if(faqlist != null && faqlist.size() > 0){
                FaqListMap = transformFaqsListToListMap(faqlist, channel, language);               
            }
        }
        
        list<Video__kav> languagePickerVideo = getIDsVideosWithLanguageAndChannel(language, channel);
        if(languagePickerVideo != null && languagePickerVideo.size() > 0){
            List<Video__kav> videolist = getVideosWithDataCategory(languagePickerVideo, uniqueName);
            if(videolist != null && videolist.size() > 0){
                VideoListMap = transformVideosListToListMap(videolist, channel, language);               
            }
        }
        List<Map<String, String>> returnListMap = new List<Map<String, String>>();
        returnListMap.addAll(HowToListMap);
        returnListMap.addAll(FaqListMap);
        returnListMap.addAll(VideoListMap);
        return JSON.serialize(returnListMap, true);
           
    }
     /*******************************rateArticle************************************
		!!!!needs changes in case of channel or language alteration!!!!
    
     public static String rateArticle(String urlName, String articleVote, String channel, String language){
        ID parentOfId;
        Vote VoteArticle;
        String articleVoteLowerCase = articleVote.toLowerCase();
        List<KnowledgeArticleVersion> kavArticle = new List<KnowledgeArticleVersion>();
        if(channel == 'partner' || channel =='customer'){
            if(language == 'en'|| language == 'ingles' || language == 'english'){
                
                kavArticle = [SELECT ID,KnowledgeArticleId FROM KnowledgeArticleVersion WHERE UrlName =: urlName AND PublishStatus = 'online' AND Language ='en_US']; 
            }
            else{
                kavArticle = [SELECT ID,KnowledgeArticleId FROM KnowledgeArticleVersion WHERE UrlName =: urlName AND PublishStatus = 'online' AND Language ='pt_BR']; 
            } 
            if(kavArticle == null)
                return null;
            try{
                if(articleVoteLowerCase == 'up' || articleVoteLowerCase == 'down'){
                    if(articleVoteLowerCase == 'up'){
                        VoteArticle = new Vote(ParentId = kavArticle[0].KnowledgeArticleId,  Type='Up');
                    }
                    else{
                        VoteArticle = new Vote(ParentId = kavArticle[0].KnowledgeArticleId, Type='Down');       
                    }
                    insert VoteArticle;
                    return 'success';
                }
                else{
                    System.debug('No such type of vote is known');
                    return 'The given type of vote doesn\'t exist';
                }
            }
            catch(exception e){
                System.debug('this user already voted');
                return null;
            } 
            
        } 	
        
        return 'Unexpected behavior, please contact someone from the backend team';
    }
    /*******************************search Article************************************
    @Return: A serialize list containing maps, keys =>'id', 'urlname', 'channel', 'language', 'title','summary', 'body', 'categoryName' and 'articleType' 
	of the article with the urlname passed as parameter
    NEEDS ALTERATION IN CASE OFF LANGUAGES CHANGES!!
    
    public static String searchArticle(String term,  String channel, String language){
        if(term == null){
            return null;
        }     
        //Not possible to use variables IN on SOSL, therefore needed to build the if case needed to support the infrastructure
        List<List<SObject>> SuggResults = new List<List<SObject>>();
        if(channel == 'partner' || channel == 'customer'){
            System.debug(term);
            String termWithNoSpecialCaract = term.replaceAll('[^a-z^A-z^0-9^ ]', '%');
            System.debug(termWithNoSpecialCaract);
            if(language == 'pt' || language =='portugues' || language =='pt_br' || language =='portuguese'){
                if(channel == 'partner'){
                    SuggResults = Search.query('FIND {'+termWithNoSpecialCaract+'} IN ALL FIELDS RETURNING How_To__kav(ID WHERE IsVisibleInPrm =true AND Language=\'pt_BR\' AND publishStatus=\'Online\' ), Faq__kav (ID WHERE IsVisibleInPrm =true AND Language=\'pt_BR\' AND publishStatus=\'Online\'), Video__kav (ID WHERE IsVisibleInPrm =true AND Language=\'pt_BR\' AND publishStatus=\'Online\' )');
                }
                else{
                    SuggResults = Search.query('FIND {'+termWithNoSpecialCaract+'} IN ALL FIELDS RETURNING How_To__kav(ID WHERE IsVisibleInCsp =true AND Language=\'pt_BR\' AND publishStatus=\'Online\' ), Faq__kav (ID WHERE IsVisibleInCsp =true AND Language=\'pt_BR\' AND publishStatus=\'Online\' ), Video__kav(ID WHERE IsVisibleInCsp =true AND Language=\'pt_BR\' AND publishStatus=\'Online\' )');
                }
            }
            if(language == 'ingles' || language =='english' || language =='en'){
                if(channel == 'partner'){
                    SuggResults = Search.query('FIND {'+termWithNoSpecialCaract+'} IN ALL FIELDS RETURNING How_To__kav(ID WHERE IsVisibleInPrm =true AND Language=\'en_US\' AND publishStatus=\'Online\' ), Faq__kav(ID WHERE IsVisibleInPrm =true AND Language=\'en_US\' AND publishStatus=\'Online\'), Video__kav(ID WHERE IsVisibleInPrm =true AND Language=\'en_US\' AND publishStatus=\'Online\' )');
                }
                else{
                    SuggResults = Search.query('FIND {'+termWithNoSpecialCaract+'} IN ALL FIELDS RETURNING How_To__kav(ID WHERE IsVisibleInCsp =true AND Language=\'en_US\' AND publishStatus=\'Online\' ), Faq__kav(ID WHERE IsVisibleInCsp =true AND Language=\'en_US\' AND publishStatus=\'Online\' ), Video__kav(ID WHERE IsVisibleInCsp =true AND Language=\'en_US\' AND publishStatus=\'Online\' )');
                }
            }
            
            System.debug(SuggResults);
            List<How_To__kav> HowTosListSearched = [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), UrlName, Summary from How_To__kav WHERE ID in:SuggResults[0]];
            List<Faq__kav> FaqsListSearched = [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), UrlName, Summary from Faq__kav WHERE ID in:SuggResults[1]];
            List<Video__kav> VideosSearched = [SELECT Id, Title, Step_by_Step__c,(SELECT DataCategoryGroupName, DataCategoryName From DataCategorySelections), UrlName, Summary from Video__kav WHERE ID in:SuggResults[2]];
            List<Map<String, String>> howToListMap = transformHowTosListToListMap(HowTosListSearched, channel, language);
            List<Map<String, String>> FaqsListMap = transformFaqsListToListMap(FaqsListSearched, channel, language);
            List<Map<String, String>> VideosMap = transformVideosListToListMap(VideosSearched, channel, language);
            List<Map<String, String>> listAllArticles = new List<Map<String, String>>();
            listAllArticles.addAll(howToListMap);
            listAllArticles.addAll(FaqsListMap);
            listAllArticles.addAll(VideosMap);
            return JSON.serialize(listAllArticles, true);
        }
     	return null;
    }

    /*******************************getAllArticlesOrderedByViews************************************
	@Return: A serialize list containing maps, keys =>'id', 'urlname', 'channel', 'language', 'title','summary', 'body', 'categoryName' and 'articleType' 
		of the article with the urlname passed as parameter
	NEEDS ALTERATION FOR THE LANGUAGES OR CHANNEL CHANGES CHANGES!!
      
    public static String getAllArticlesOrderedByViews(String channel, String language){
        list<KnowledgeArticleVersion> articlesOrderedByView = new list<KnowledgeArticleVersion>();
        if(channel =='partner' || channel =='customer' && (language == 'pt' ||  language == 'portugues' || language == 'pt_BR' || language == 'en' || language == 'english' )){
            if(language == 'pt' || language =='portuguese' || language == 'portugues' || language == 'pt_BR'){
                if(channel == 'partner'){
                    articlesOrderedByView = [SELECT ID, articleType, Summary, Title, UrlName, MasterVersionId FROM KnowledgeArticleVersion WHERE (Language='pt_BR' AND IsVisibleInPrm = true AND publishStatus='online') ORDER BY ArticleTotalViewCount DESC LIMIT 12];
                }
                else{
                    articlesOrderedByView = [SELECT ID, articleType, Summary, Title, UrlName, MasterVersionId FROM KnowledgeArticleVersion WHERE (Language='pt_BR' AND IsVisibleInCsp = true AND publishStatus='online') ORDER BY ArticleTotalViewCount DESC LIMIT 12];
                }
            }
            else{
                if(channel == 'partner'){
                    articlesOrderedByView = [SELECT ID, articleType, Summary, Title, UrlName, MasterVersionId FROM KnowledgeArticleVersion WHERE (Language='en_US' AND IsVisibleInPrm = true AND publishStatus='online') ORDER BY ArticleTotalViewCount DESC LIMIT 12];
                }
                else{
                    articlesOrderedByView = [SELECT ID, articleType, Summary, Title, UrlName, MasterVersionId FROM KnowledgeArticleVersion WHERE (Language='en_US' AND IsVisibleInCsp = true AND publishStatus='online') ORDER BY ArticleTotalViewCount DESC LIMIT 12];
                }
            }
        }
        else{
            System.debug('unexpected language or channel values, check if the language is pt or en AND if the channel is either partner or customer');
            return null;
        }
        List<Map<string, string>> cardsOrderedListMap = new List<Map<string, string>>();
        for(KnowledgeArticleVersion article: articlesOrderedByView){
            Map<string, string> cardMap = new Map<String, String>();
            cardMap.put('id', article.MasterVersionId);
            cardMap.put('urlName', article.UrlName);
            cardMap.put('title', article.Title);
            cardMap.put('summary', article.Summary);
            if(article.articleType == 'video__kav'){
               cardMap.put('cardType', 'video'); 
            }
            if(article.articleType == 'faq__kav'){
               cardMap.put('cardType', 'faq'); 
            }
            if(article.articleType == 'How_To__kav'){
                cardMap.put('cardType', 'guia'); 
            }
            cardsOrderedListMap.add(cardMap);
        }
        
        return JSON.serialize(cardsOrderedListMap, true);
    } 
     /*******************************getArticlesByType************************************
	 @Return: A serialize list containing maps, keys =>'id', 'urlname', 'channel', 'language', 'title','summary', 'body', 'categoryName' and 'articleType' 
		of the article with the urlname passed as parameter
		NEEDS ALTERATION FOR ARTICLE TYPES CHANGES!!
    public static String getArticlesByType(String channel, String language, String articleType){
        String articleTypeLowerCase = articleType.toLowerCase();
        if(articleTypeLowerCase == 'faq' || articleTypeLowerCase == 'video'|| articleTypeLowerCase =='howto' || articleTypeLowerCase =='howtos' || articleTypeLowerCase =='videos' || articleTypeLowerCase == 'faqs' ){
            
            if(articleTypeLowerCase == 'howto' || articleTypeLowerCase == 'howtos'){
                List<How_To__kav> howToList = getIDsHowTosWithLanguageAndChannel(language, channel);
                if(howToList == null){
                    return null;
                }
                return JSON.serialize(transformHowTosListToListMap(howToList, channel, language), true);
            }
            if(articleTypeLowerCase == 'faq' || articleTypeLowerCase == 'faqs'){
                List<Faq__kav> FaqsList = getIDsFaqsWithLanguageAndChannel(language, channel);
                if(FaqsList == null){
                    return null;
                }
                return JSON.serialize(transformFaqsListToListMap(FaqsList, channel, language), true);
            }
            if(articleTypeLowerCase == 'video' || articleTypeLowerCase == 'videos'){
                List<Video__kav> videosList = getIDsVideosWithLanguageAndChannel(language, channel);
                if(videosList == null){
                    return null;
                }
                return JSON.serialize(transformVideosListToListMap(videosList, channel, language), true);
            }
        }
        
        return null;
    }
    
    public static void insertKBSearchTerm(String loginId, String searchTerm, String channel, String language){
        if(loginId == null || searchTerm == null || channel == null || language == null){
            return;
        }
        string channelLowerCase = channel.toLowerCase();
        string languageLowerCase = language.toLowerCase();
        String country='';
        if(languageLowerCase=='pt_br' || languageLowerCase=='pt' || languageLowerCase=='portugues'|| languageLowerCase=='portuguese' ){
            country='Portugal';
        }
        if(languageLowerCase=='es' || languageLowerCase=='espanhol' || languageLowerCase=='espanol'|| languageLowerCase=='spanish' ){
            country='Spain';
        }
        if(languageLowerCase=='en' || languageLowerCase=='english' || languageLowerCase=='ingles'|| languageLowerCase=='francais' ){
            country='England';
        }
        if(country !=''){
            KnowledgeBase_Search__c kbsearch = new KnowledgeBase_Search__c(Login__c = loginId, Search_Term__c = searchTerm, Country__c = country);
            insert kbsearch;
            System.debug(kbsearch.id);
        }
        else{
            system.debug('invalid country');
        }
        
    }*/
    
}