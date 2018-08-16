//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "structs.mqh";
#include "CItems.mqh";
#include "CTdiStoch.mqh";
#include "COsMaDivStoch.mqh";

class CSignal
{  
   private:
      Setting m_St;
      CTdiStoch* oTdiStoch;
      COsMaDivStoch* oOsMaDivStoch;
      
   public:
   
      CSignal(){
         oTdiStoch = new CTdiStoch();
         oOsMaDivStoch = new COsMaDivStoch();
      };
      void Init(Setting &st);
      Setting GetSetting(void);
      Signal GetEntrySignal(void);
      bool isExitSignal(CItems *oItems);
};

void CSignal::Init(Setting &st){
   m_St = st;
}

Setting CSignal::GetSetting(){
   return m_St;
}

Signal CSignal::GetEntrySignal(){
   Signal sr = {-1,-1,false,"",""};
   if(m_St.isUse_TdiStochEntryM5){
      sr = oTdiStoch.EntrySignalM5();
      if(sr.sign>-1 && sr.Level>0){
         return sr;
      }
   }
   if(m_St.isUse_TdiStochEntryH1){
      sr = oTdiStoch.EntrySignalH1();
      if(sr.sign>-1 && sr.Level>0){
         return sr;
      }
   }
   if(m_St.isUse_OsMaDivStochEntryH1){
      sr = oOsMaDivStoch.EntrySignalH1();
      if(sr.sign>-1 && sr.Level>0){
         return sr;
      }
   }
   return sr;
}

//在order管理器中循环判断
bool CSignal::isExitSignal(CItems *oItems){
   Signal sr;
   if(oItems.GetEntryStrategy() == "CTdiStochM5"){
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
