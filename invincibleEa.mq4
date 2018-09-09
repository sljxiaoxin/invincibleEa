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
#include "inc\COrder.mqh";

extern int       MagicNumber          = 20180808;
extern double    Lots                 = 0.1;
extern int       intTP                = 100;
extern int       intSL                = 15;
extern int       intMaxItems          = 5;
extern int       intMaxActiveItems    = 2;
extern double    distance             = 5;      

extern string    strUseStochEntryM5  = "Stoch entry m5";
extern bool      isUse_StochEntryM5   = false;

extern string    strUseStochEntryH1  = "Stoch entry H1";
extern bool      isUse_StochEntryH1   = false;

extern string    strUseMaEntryM15  = "MA entry m15";
extern bool      isUse_MaEntryM15   = true;

extern string    strUseMaEntryH1  = "MA entry H1";
extern bool      isUse_MaEntryH1   = false;

extern string    strUseTdiStochEntryM5  = "TDI + stoch entry m5";
extern bool      isUse_TdiStochEntryM5   = false;

extern string    strUseTdiStochEntryH1  = "TDI + stoch entry H1";
extern bool      isUse_TdiStochEntryH1   = false;

extern string    strUseOsMaDivStochEntryH1  = "osMa Divergence + stoch entry H1";
extern bool      isUse_OsMaDivStochEntryH1   = false;

extern string    strMarti  = "marti relation setting";
extern int       gridSize  = 50;
extern int       maxMarti  = 0;
extern double    mutilplier = 1;

datetime CheckTimeM1;

COrder*  oCOrder = NULL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   Print("begin");
   Setting* st = new Setting();
   st.MagicNumber = MagicNumber;
   st.Lots = Lots;
   st.intTP = intTP;
   st.intSL = intSL;
   st.distance = distance;
   st.isUse_MaEntryM15 = isUse_MaEntryM15;
   st.isUse_MaEntryH1 = isUse_MaEntryH1;
   st.isUse_StochEntryM5 = isUse_StochEntryM5;
   st.isUse_StochEntryH1 = isUse_StochEntryH1;
   st.isUse_TdiStochEntryM5 = isUse_TdiStochEntryM5;
   st.isUse_TdiStochEntryH1 = isUse_TdiStochEntryH1;
   st.isUse_OsMaDivStochEntryH1 = isUse_OsMaDivStochEntryH1;
   st.intMaxItems = intMaxItems;
   st.intMaxActiveItems = intMaxActiveItems;
   st.gridSize = gridSize;
   st.maxMarti = maxMarti;
   st.mutilplier = mutilplier;
   
   if(oCOrder == NULL){
      oCOrder = new COrder();
   }
   oCOrder.Init(st);
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
     if(CheckTimeM1 == iTime(NULL,PERIOD_M1,0)){
      
     }else{
         CheckTimeM1 = iTime(NULL,PERIOD_M1,0);
         //Print("OnTick CheckTimeM1=",CheckTimeM1);
         oCOrder.AccountPortect();
         oCOrder.Entry();
     }
     
}


void subPrintDetails()
{
   //
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";

   sComment = sp;
   sComment = sComment + "TotalItems = " + oCOrder.TotalItems() + NL; 
   sComment = sComment + sp;
   sComment = sComment + "TotalItemsActive = " + oCOrder.TotalItemsActive() + NL; 
   sComment = sComment + sp;
   sComment = sComment + "Lots=" + DoubleToStr(Lots,2) + NL;
   Comment(sComment);
}


