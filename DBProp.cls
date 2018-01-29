public class DBProp {
   // public string ClientType {get; set; }
    public String DenomEmp { get; set; }
    public String DenoFantasyEmp { get; set; }
    public Integer IndRisco { get; set; }
    public String CapcFin { get; set; }       
    public string OpCred { get; set;}
    public Integer RiscoInforma { get;set; }
  //  public string ReqNif { get;set; }
    public Decimal CapitalSocial { get;set; }
    public Date DataConstituicao { get;set; }
    public Integer TotIncidentes { get;set; }
    public Decimal TotValorIncidentes { get;set; }
    public Integer TotEmpregados { get;set; }
    public Decimal ResultLiqUltimoAno { get;set; }
    public String CAE { get;set; }
    public String DescricaoCAE { get;set; }
    public String Nome { get;set; }
    public String NumeroContribuinte { get;set; }
    public String NomeVia { get;set; }
    public String Localidade { get;set; }
    public String CodigoPostal { get;set; }
    public String EnderecoPostal { get;set; }
    public String Telefone { get;set; }
    public String FormaObrigar { get;set; }
    public String FormaJuridica { get;set; }
    public String SituacaoContributiva { get;set; }
    public Integer PercentilScore { get;set; } 
    public List<Contacto> ListContacto { get;set; } 
    public class Contacto {
    	public String Nome { get;set; } 
       	public String Apelido1 { get;set; } 
        public String Apelido2 { get;set; } 
        public String Tipo  { get;set; } 
    }
    public String email { get;set; } 
    public String website { get;set; } 
    public Decimal FormaObrigarVal {get;set;}
    public Decimal VendasUltimoAno { get;set; } 
    public String indApresInsol { get;set; }
    public String indProcessoRevitalizacao { get;set; }
    public string ValorEstado { get;set;}
    public integer AnoBalanco { get;set;}
    public Decimal ResultLiqAno_n_1 { get;set; }
    public Decimal ResultLiqAno_n_2 { get;set; }
    public Decimal Vendas_n_1 { get;set; }
    public Decimal Vendas_n_2 { get;set; }

     //new field for Spanish WS
    public Integer ScoreLiquidez { get;set;}
    
 }