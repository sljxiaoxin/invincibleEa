//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "structs.mqh";
#include "CItems.mqh";
#include "CStoch.mqh";
#include "CTdiStoch.mqh";
#include "COsMaDivStoch.mqh";

class CSignal
{  
   private:
      Setting* m_St;
      CStoch* oStoch;
      CTdiStoch* oTdiStoch;
      COsMaDivStoch* oOsMaDivStoch;
      
   public:
   
      CSignal(){
         oStoch = new CStoch();
         oTdiStoch = new CTdiStoch();
         oOsMaDivStoch = new COsMaDivStoch();
      };
      void Init(Setting* st);
      Setting* GetSetting(void);
      Signal* GetEntrySignal(void);
      bool isExitSignal(CItems *oItems);
};

void CSignal::Init(Setting* st){
   m_St = st;
}

Setting* CSignal::GetSetting(){
   return m_St;
}

Signal* CSignal::GetEntrySignal(){
   Signal* sr = new Signal();
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_St.isUse_TdiStochEntryH1){
      sr = oTdiStoch.EntrySignalH1();
      if(sr.sign>-1 && sr.Level>-1){
         sr.intTP = 50;
         sr.intHD = 20;
         sr.intSL = 15;
         Print("CSignal::GetEntrySignal TDIH1->",sr.sign,", ",sr.Level);
         return sr;
      }
   }
   
   if(m_St.isUse_StochEntryH1){
      sr = oStoch.EntrySignalH1();
      sr.intHD = 20;
      sr.intTP = 30;
      sr.intSL = 15;
      if(sr.sign>-1 && sr.Level>-1){
         Print("CSignal::GetEntrySignal StochH1->",sr.sign,", ",sr.Level);
         return sr;
      }
   }
   
   if(m_St.isUse_StochEntryM5){
      sr = oStoch.EntrySignalM5();
      sr.intHD = 10;
      sr.intTP = 15;
      sr.intSL = 12;
      if(sr.sign>-1 && sr.Level>-1){
         Print("CSignal::GetEntrySignal StochM5->",sr.sign,", ",sr.Level);
         return sr;
      }
   }
   
   if(m_St.isUse_TdiStochEntryM5){
      sr = oTdiStoch.EntrySignalM5();
      sr.intHD = 15;
      sr.intTP = 25;
      sr.intSL = 12;
      if(sr.sign>-1 && sr.Level>0){
         Print("CSignal::GetEntrySignal TDIM5->",sr.sign,", ",sr.Level);
         return sr;
      }
   }
   
   if(m_St.isUse_OsMaDivStochEntryH1){
      sr = oOsMaDivStoch.EntrySignalH1();
      sr.intHD = 15;
      sr.intTP = 35;
      sr.intSL = 12;
      if(sr.sign>-1 && sr.Level>0){
         Print("CSignal::GetEntrySignal OsMaDivH1->",sr.sign,", ",sr.Level);
         return sr;
      }
   }
   return sr;
}

//在order管理器中循环判断
bool CSignal::isExitSignal(CItems *oItems){
   Signal* sr;
   if(oItems.GetEntryStrategy() == "CStochM5"){
      sr = oStoch.ExitSignalM5();
      if(sr.sign == OP_BUY && oItems.GetOpType() == OP_BUY){
         return true;
      }
      if(sr.sign == OP_SELL && oItems.GetOpType() == OP_SELL){
         return true;
      }
   }else if(oItems.GetEntryStrategy() == "CStochH1"){
      sr = oStoch.ExitSignalH1();
      if(sr.sign == OP_BUY && oItems.GetOpType() == OP_BUY){
         return true;
      }
      if(sr.sign == OP_SELL && oItems.GetOpType() == OP_SELL){
         return true;
      }
   }else if(oItems.GetEntryStrategy() == "CTdiStochM5"){
      sr = oTdiStoch.ExitSignalM5();
      if(sr.sign == OP_BUY && oItems.GetOpType() == OP_BUY){
         return true;
      }
      if(sr.sign == OP_SELL && oItems.GetOpType() == OP_SELL){
         return true;
      }
   }else if(oItems.GetEntryStrategy() == "CTdiStochH1"){
      sr = oTdiStoch.ExitSignalH1();
      if(sr.sign == OP_BUY && oItems.GetOpType() == OP_BUY){
         return true;
      }
      if(sr.sign == OP_SELL && oItems.GetOpType() == OP_SELL){
         return true;
      }
   }else if(oItems.GetEntryStrategy() == "COsMaDivStochH1"){
      sr = oOsMaDivStoch.ExitSignalH1();
      if(sr.sign == OP_BUY && oItems.GetOpType() == OP_BUY){
         return true;
      }
      if(sr.sign == OP_SELL && oItems.GetOpType() == OP_SELL){
         return true;
      }
   }
   return false;
}
