//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015."
#property link      "http://www.mql5.com"

#include "structs.mqh";
#include "dictionary.mqh"
#include "CItems.mqh";
#include "CSignal.mqh";
#include "CTrade.mqh";

class COrder
{
   private:
      
      double m_Lots;
      double m_IntTP;
      double m_IntSL;
      int    m_IntMaxItems;
      int    m_IntMaxActiveItems;
      CTrade* oTrade;
      CSignal* oSignal;
      CDictionary *oDictionary;
   public:
      COrder(CSignal* oSig){
         oDictionary = new CDictionary();
         oTrade = new CTrade();
         oSignal = oSig;
         
      };
      
      void Init(Setting &st);
      
      bool Entry(void);
      void AccountPortect(void);
      
      void Hedg(int ticket);
      void UnHedg(void);
      void TrailingStop(CItems* item);
      
      
      
      bool Buy(Signal &sr);
      bool Sell(Signal &sr);
      
      
      double GetItemProfitPips(CItems* item);
      int  TotalItems(void);          //all item
      int  TotalItemsActive(void);    //no hedg
      bool CloseItem(CItems* item);
      bool isItemAllClosed(CItems* item);

};

void COrder::Init(Setting &st){
   m_Lots = st.Lots;
   m_IntTP = st.intTP;
   m_IntSL = st.intSL;
   m_IntMaxItems = st.intMaxItems;
   m_IntMaxActiveItems = st.intMaxActiveItems;
}

void COrder::AccountPortect(void){
   int arrOrderDel[20];
   int k = 0;
   for(int j=0;j<20;j++){
      arrOrderDel[j]=0;
   }
   CItems* currItem = oDictionary.GetFirstNode();
   for(int i = 1; (currItem != NULL && CheckPointer(currItem)!=POINTER_INVALID); i++)
   {
      //1、check item's orders all closed
      if(isItemAllClosed(currItem)){
         arrOrderDel[k] = currItem.GetTicket();
         k += 1;
         currItem = oDictionary.GetNextNode();
         continue;
      }
      //2、hedg dealing
      if(currItem.Hedg == 0){
         double profitPips = oTrade.GetProfitPips(currItem.GetTicket());
         if(profitPips<0 && MathAbs(profitPips)>m_IntSL){
            Hedg(currItem.GetTicket());
         }
      }
      
      //3、tp check close item dealing
      if(oSignal.isExitSignal(currItem)){
         if(GetItemProfitPips(currItem) >0) CloseItem(currItem);
      }
      
      //4、TrailingStop dealing
      if(currItem.Hedg == 0){
         TrailingStop(currItem);
      }
      
      currItem = oDictionary.GetNextNode();
   }
   for(int m=0;m<20;m++){
      if(arrOrderDel[m] > 0){
         oDictionary.DeleteObjectByKey(arrOrderDel[m]);  //delete closed item
         Print("DeleteObjectByKey:",arrOrderDel[m]);
      }
   }
}

void COrder::Hedg(int ticket){
   CItems* item = oDictionary.GetObjectByKey(ticket);
   if(item.Hedg != 0){
      return ;
   }
   int t = 0;
   if(item.GetOpType() == OP_BUY){
      t = oTrade.Sell(item.getLots(), 0, 0, ticket);
      if(t > 0) item.Hedg = t;
   }
   if(item.GetOpType() == OP_SELL){
      t = oTrade.Buy(item.getLots(), 0, 0, ticket);
      if(t > 0) item.Hedg = t;
   }
}

void COrder::UnHedg(void){

   
}

void COrder::TrailingStop(CItems* item){
   int ticket = item.GetTicket();
   //double profitPips = oTrade.GetProfitPips(ticket);
   double stoploss = oTrade.GetOrderStopLoss(ticket);
   if(stoploss == -1){
      return;
   }
   double oop = item.GetOop();
   double Pip = oTrade.GetPip();
   if(item.GetOpType() == OP_BUY){
      if(stoploss - oop <1*Pip && Close[1] - oop > 12*Pip && Ask - oop > 12*Pip){
         oTrade.Modify(ticket, oop, NormalizeDouble(oop + 2*Pip, Digits));
      }
   }
   if(item.GetOpType() == OP_SELL){
      if(oop - stoploss <1*Pip &&  oop - Close[1] > 12*Pip && oop - Bid > 12*Pip){
         oTrade.Modify(ticket, oop, NormalizeDouble(oop - 2*Pip, Digits));
      }
   }
}

bool COrder::Entry(void){
   if(TotalItems()>=m_IntMaxItems || TotalItemsActive()>=m_IntMaxActiveItems){
      return false;
   }
   Signal sr = oSignal.GetEntrySignal();
   if(sr.sign == OP_BUY){
      Buy(sr);
   }else if(sr.sign == OP_SELL){
      Sell(sr);
   }else{
      return false;
   }
   return true;
}

bool COrder::Buy(Signal &sr){

   //TODO ADD Filter buy
   int t = 0;
   double oop;
   t = oTrade.Buy(m_Lots, 0, 0, sr.comment);
   if(t != 0){
      if(OrderSelect(t, SELECT_BY_TICKET)==true){
         oop = OrderOpenPrice();
      }
      oDictionary.AddObject(t, new CItems(t, m_Lots, m_IntTP, m_IntSL, sr.strategy, oop, OP_BUY));
      return true;
   }else{
      return false;
   }
}

bool COrder::Sell(Signal &sr){

   //TODO ADD Filter sell
   int t = 0;
   double oop;
   t = oTrade.Sell(m_Lots, 0, 0, sr.comment);
   if(t != 0){
      if(OrderSelect(t, SELECT_BY_TICKET)==true){
         oop = OrderOpenPrice();
      }
      oDictionary.AddObject(t, new CItems(t, m_Lots, m_IntTP, m_IntSL, sr.strategy, oop, OP_SELL));
      return true;
   }else{
      return false;
   }
}


double COrder::GetItemProfitPips(CItems* item){
   double profitPips = oTrade.GetProfitPips(item.GetTicket());
   if(item.Hedg != 0){
      profitPips += oTrade.GetProfitPips(item.Hedg);
   }
   for(int i=0;i<item.Marti.Total();i++){
      profitPips += oTrade.GetProfitPips(item.Marti.At(i));
   }
   return profitPips;
}


int COrder::TotalItems(){
   return oDictionary.Total();
}

int COrder::TotalItemsActive(){
   int count = 0;
   CItems* currItem = oDictionary.GetFirstNode();
   for(int i = 1; (currItem != NULL && CheckPointer(currItem)!=POINTER_INVALID); i++)
   {
      if(currItem.Hedg == 0){
         count += 1;
      }
      currItem = oDictionary.GetNextNode();
   }
   return count;
}

bool COrder::CloseItem(CItems* item){
   if(item.GetTicket() != 0){
      oTrade.Close(item.GetTicket());
   }
   if(item.Hedg != 0){
      oTrade.Close(item.Hedg);
   }
   for(int i=0;i<item.Marti.Total();i++){
      oTrade.Close(item.Marti.At(i));
   }
   return true;
}

bool COrder::isItemAllClosed(CItems* item){
   if(!oTrade.isOrderClosed(item.GetTicket())){
      return false;
   }
   if(item.Hedg != 0){
      if(!oTrade.isOrderClosed(item.Hedg)){
         return false;
      }
   }
   for(int i=0;i<item.Marti.Total();i++){
      if(!oTrade.isOrderClosed(item.Marti.At(i))){
         return false;
      }
   }
   return true;
}




