//+------------------------------------------------------------------+
//|     
//|                                                      
//|     
    //double tsl_1 = iCustom(NULL,PERIOD_M5,"TDI Red Green",5,1);  //Trade Signal Line
   //double tsl_2 = iCustom(NULL,PERIOD_M5,"TDI Red Green",5,2);  //Trade Signal Line
   //double bullishDivVal = iCustom(NULL,PERIOD_M5,"FX5_Divergence_v2.0_yjx",2,2);  //up
   //double bearishDivVal = iCustom(NULL,PERIOD_M5,"FX5_Divergence_v2.0_yjx",3,2);  //down
   //double stoch14 = iStochastic(NULL, PERIOD_M1, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
   //double stoch100 = iStochastic(NULL, PERIOD_M1, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);                                         
//+------------------------------------------------------------------+
#property copyright "xiaoxin003"
#property link      "yangjx009@139.com"
#property version   "1.0"
#property strict

#include <Arrays\ArrayInt.mqh>
#include "inc\structs.mqh";
#include "inc\CSignal.mqh";
#include "inc\COrder.mqh";

extern int       MagicNumber          = 20180808;
extern double    Lots                 = 0.1;
extern int       intTP                = 100;
extern int       intSL                = 0;
extern int       intMaxItems          = 6;
extern int       intMaxActiveItems    = 3;  //no hedg
extern double    distance             = 5;      

extern string    strUseTdiStochEntryM5  = "TDI + stoch entry m5";
extern bool      isUse_TdiStochEntryM5   = true;

extern string    strUseTdiStochEntryH1  = "TDI + stoch entry H1";
extern bool      isUse_TdiStochEntryH1   = true;

extern string    strUseOsMaDivStochEntryH1  = "osMa Divergence + stoch entry H1";
extern bool      isUse_OsMaDivStochEntryH1   = true;


CSignal* oSignal = NULL;
COrder*  oCOrder = NULL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   Print("begin");
   Setting st;
   st.MagicNumber = MagicNumber;
   st.Lots = Lots;
   st.intTP = intTP;
   st.intSL = intSL;
   st.distance = distance;
   st.isUse_TdiStochEntryM5 = isUse_TdiStochEntryM5;
   st.isUse_TdiStochEntryH1 = isUse_TdiStochEntryH1;
   st.isUse_OsMaDivStochEntryH1 = isUse_OsMaDivStochEntryH1;
   st.intMaxItems = intMaxItems;
   st.intMaxActiveItems = intMaxActiveItems;
   
   if(oSignal == NULL){
      oSignal = new CSignal();
      oCOrder = new COrder(oSignal);
   }
   oSignal.init(st);
   oCOrder.init(st);
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("deinit");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
{
     subPrintDetails();
     oCOrder.AccountPortect();
     oCOrder.Entry();
     
}


void subPrintDetails()
{
   //
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";

   sComment = sp;
   sComment = sComment + "Net = " + TotalNetProfit() + NL; 
   sComment = sComment + sp;
   sComment = sComment + "Lots=" + DoubleToStr(Lots,2) + NL;
   Comment(sComment);
}

