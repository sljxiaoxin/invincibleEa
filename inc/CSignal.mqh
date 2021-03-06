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
#include "CMa.mqh";
#include "CTrade.mqh";

class CSignal
{  
   private:
      Setting* m_St;
      CStoch* oStoch;
      CTdiStoch* oTdiStoch;
      COsMaDivStoch* oOsMaDivStoch;
      CMa* oMa;
      
   public:
   
      CSignal(CTrade* _oCTrade){
         oStoch = new CStoch();
         oTdiStoch = new CTdiStoch();
         oOsMaDivStoch = new COsMaDivStoch();
         oMa = new CMa(_oCTrade);
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
   
   if(m_St.isUse_MaEntryH1){
      sr = oMa.EntrySignalH1();
      if(sr.sign>-1 && sr.Level>-1){
         sr.intTP = 100;
         sr.intHD = 50;
         sr.intSL = 15;
         Print("CSignal::GetEntrySignal CMaH1->",sr.sign,", ",sr.Level);
         return sr;
      }
   }
   
   if(m_St.isUse_TdiStochEntryH1){
      sr = oTdiStoch.EntrySignalH1();
      if(sr.sign>-1 && sr.Level>-1){
         sr.intTP = 20;
         sr.intHD = 15;
         sr.intSL = 15;
         Print("CSignal::GetEntrySignal TDIH1->",sr.sign,", ",sr.Level);
         return sr;
      }
   }
   
   if(m_St.isUse_StochEntryH1){
      sr = oStoch.EntrySignalH1();
      sr.intHD = 20;
      sr.intTP = 20;
      sr.intSL = 15;
      if(sr.sign>-1 && sr.Level>-1){
         Print("CSignal::GetEntrySignal StochH1->",sr.sign,", ",sr.Level);
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
   
   ///////////////////////M5///////////////////////////
   
   
   if(m_St.isUse_StochEntryM5){
      sr = oStoch.EntrySignalM5();
      sr.intHD = 10;
      sr.intTP = 11;
      sr.intSL = 12;
      if(sr.sign>-1 && sr.Level>-1){
         Print("CSignal::GetEntrySignal StochM5->",sr.sign,", ",sr.Level);
         return sr;
      }
   }
   
   if(m_St.isUse_MaEntryM5){
      
      sr = oMa.EntrySignalM5();
      //Print("CSignal::GetEntrySignal CMaM5->check->",sr.sign,", ",sr.Level);
      if(sr.sign>-1 && sr.Level>-1){
         sr.intTP = 80;
         sr.intHD = 20;
         sr.intSL = 40;
         Print("CSignal::GetEntrySignal CMaM5->",sr.sign,", ",sr.Level);
         return sr;
      }
   }
   
   if(m_St.isUse_TdiStochEntryM5){
      sr = oTdiStoch.EntrySignalM5();
      sr.intHD = 15;
      sr.intTP = 11;
      sr.intSL = 12;
      if(sr.sign>-1 && sr.Level>0){
         Print("CSignal::GetEntrySignal TDIM5->",sr.sign,", ",sr.Level);
         return sr;
      }
   }
   
   
   return sr;
}

//在order管理器中循环判断
bool CSignal::isExitSignal(CItems *oItems){
   Signal* sr;
   if(oItems.GetEntryStrategy() == "CMaM5"){
      sr = oMa.ExitSignalM5();
      
      if(sr.sign == OP_BUY && oItems.GetOpType() == OP_BUY){
         Print("CSignal::isExitSignal CMaM5-> buy exit");
         return true;
      }
      if(sr.sign == OP_SELL && oItems.GetOpType() == OP_SELL){
          Print("CSignal::isExitSignal CMaM5-> sell exit");
         return true;
      }
   }else if(oItems.GetEntryStrategy() == "CMaH1"){
      sr = oMa.ExitSignalH1();
      if(sr.sign == OP_BUY && oItems.GetOpType() == OP_BUY){
         return true;
      }
      if(sr.sign == OP_SELL && oItems.GetOpType() == OP_SELL){
         return true;
      }
   }else if(oItems.GetEntryStrategy() == "CStochM5"){
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
