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



#include "inc\dictionary.mqh" 
#include "inc\trademgr.mqh"   
#include "inc\citems.mqh"     


extern int       MagicNumber          = 20180808;
extern double    Lots                 = 0.1;
extern int       intTP                = 100;
extern int       intSL                = 0;
extern double    distance             = 5;      

extern string    strUseTdiStochEntryM5  = "TDI + stoch entry m5";
extern bool      isUseTdiStochEntryM5   = true;

extern string    strUseTdiStochEntryH1  = "TDI + stoch entry H1";
extern bool      isUseTdiStochEntryH1   = false;

extern string    strUseOsMaDivStochEntryH1  = "osMa Divergence + stoch entry H1";
extern bool      isUseOsMaDivStochEntryH1   = true;


CSignal* oSignal = NULL;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   Print("begin");
   
   if(oSignal == NULL){
      oSignal = new CSignal();
   }
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
     Signal sr = oSignal.GetSignal();
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


