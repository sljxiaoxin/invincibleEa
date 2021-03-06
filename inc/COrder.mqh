//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015."
#property link      "http://www.mql5.com"
#include <Arrays\ArrayString.mqh>
#include "structs.mqh";
#include "dictionary.mqh";
#include "CItems.mqh";
#include "CSignal.mqh";
#include "CTrade.mqh";
#include "CMarti.mqh";

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
      CDictionary* oDictionary;
      CMarti* oMarti;
      
      //CArrayString* oArrActiveStrategy;
      
   public:
      COrder(){
        // oArrActiveStrategy = new CArrayString;
         oDictionary = new CDictionary();
         oTrade = new CTrade();
         oSignal = new CSignal(oTrade);
         oMarti = new CMarti(oTrade, oDictionary);
      };
      
      void Init(Setting* st);
      
      bool Entry(void);
      void AccountPortect(void);
      
      void Hedg(int ticket);
      bool UnHedg(Signal &sr);
      void TrailingStop(CItems* item);
      
      
      
      bool Buy(Signal &sr);
      bool Sell(Signal &sr);
      
      
      double GetItemProfitPips(CItems* item);
      int  TotalItems(void);          //all item
      int  TotalItemsActive(void);    //no hedg
      bool CloseItem(CItems* item);
      bool isItemAllClosed(CItems* item);
      bool isActiveStrategy(int opType, string strategy);

};

void COrder::Init(Setting* st){
   oSignal.Init(st);
   
   m_Lots = st.Lots;
   m_IntTP = st.intTP;
   m_IntSL = st.intSL;
   m_IntMaxItems = st.intMaxItems;
   m_IntMaxActiveItems = st.intMaxActiveItems;
   //init Marti
   oMarti.Init(st.gridSize, st.maxMarti, st.mutilplier);
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
      /*
      //2、hedg dealing
      if(currItem.Hedg == 0){
         double profitPips = oTrade.GetProfitPips(currItem.GetTicket());
        // Print("COrder::AccountPortect profitPips=",profitPips);
         if(profitPips<0  && MathAbs(profitPips)>currItem.GetHD()){
            Hedg(currItem.GetTicket());
         }
      }
      */
      
      //3、tp check close item dealing
      if(oSignal.isExitSignal(currItem)){
         Print("COrder::AccountPortect isExitSignal ticket=",currItem.GetTicket());
        // if(GetItemProfitPips(currItem) >0) 
         CloseItem(currItem);
      }
      
      if(GetItemProfitPips(currItem) > currItem.GetTP()){
         Print("COrder::AccountPortect takeprofit ticket=",currItem.GetTicket());
         CloseItem(currItem);
      }
      
      //4、TrailingStop dealing
      if(currItem.Hedg == 0){
         TrailingStop(currItem);
      }
      
      //5、after unHedg tp or sl check
      if(currItem.Hedg != 0){
         if(currItem.GetTpPrice()>0 && currItem.GetSlPrice()>0){
            if(currItem.GetTpPrice() > currItem.GetSlPrice()){
               //buy
               if(Ask>currItem.GetTpPrice() || Ask<currItem.GetSlPrice()){
                  CloseItem(currItem);
               }
            }
            if(currItem.GetTpPrice() < currItem.GetSlPrice()){
               //sell
               if(Bid<currItem.GetTpPrice() || Bid>currItem.GetSlPrice()){
                  CloseItem(currItem);
               }
            }
         }
      }
      //5、Marti check
      //oMarti.CheckMarti(currItem);
      
      
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
      t = oTrade.Sell(item.GetLots(), 0, 0, ticket);
      if(t > 0) item.Hedg = t;
   }
   if(item.GetOpType() == OP_SELL){
      t = oTrade.Buy(item.GetLots(), 0, 0, ticket);
      if(t > 0) item.Hedg = t;
   }
}

bool COrder::UnHedg(Signal &sr){
   if(!sr.unHedg){
      return false;
   }
   //foreach items if heged items 
   int ticket = 0;
   int leaveOpType = -1;
   double profits = -9999;
   double orderProfits;
   CItems* item;
   CItems* currItem = oDictionary.GetFirstNode();
   for(int i = 1; (currItem != NULL && CheckPointer(currItem)!=POINTER_INVALID); i++)
   {
      Print("COrder::UnHedg currItem.Hedg=",currItem.Hedg,"; currItem.GetTicket()=",currItem.GetTicket());
      if(currItem.Hedg != 0 && currItem.Marti.Total() == 0 && !oTrade.isOrderClosed(currItem.GetTicket()) && !oTrade.isOrderClosed(currItem.Hedg)){
         if(sr.sign == OP_BUY){
            if(currItem.GetOpType() == OP_BUY){
               orderProfits = oTrade.GetProfitPips(currItem.Hedg);
               if(orderProfits>profits){
                  profits = orderProfits;
                  ticket = currItem.Hedg;
                  leaveOpType = OP_BUY;
                  item = oDictionary.GetObjectByKey(currItem.GetTicket());
               }
            }
            if(currItem.GetOpType() == OP_SELL){
               orderProfits = oTrade.GetProfitPips(currItem.GetTicket());
               if(orderProfits>profits){
                  profits = orderProfits;
                  ticket = currItem.GetTicket();
                  leaveOpType = OP_BUY;
                  item = oDictionary.GetObjectByKey(currItem.GetTicket());
               }
            }
         }
         if(sr.sign == OP_SELL){
            if(currItem.GetOpType() == OP_BUY){
               orderProfits = oTrade.GetProfitPips(currItem.GetTicket());
               if(orderProfits>profits){
                  profits = orderProfits;
                  ticket = currItem.GetTicket();
                  leaveOpType = OP_SELL;
                  item = oDictionary.GetObjectByKey(currItem.GetTicket());
               }
            }
            if(currItem.GetOpType() == OP_SELL){
               orderProfits = oTrade.GetProfitPips(currItem.Hedg);
               if(orderProfits>profits){
                  profits = orderProfits;
                  ticket = currItem.Hedg;
                  leaveOpType = OP_SELL;
                  item = oDictionary.GetObjectByKey(currItem.GetTicket());
               }
            }
         }
      }
      currItem = oDictionary.GetNextNode();
   }
   if(ticket >0){
      oTrade.Close(ticket);
      if(leaveOpType == OP_BUY){
         int tp = item.GetTP();
         int sl = item.GetSL();
         double Pip = oTrade.GetPip();
         double tpPrice = NormalizeDouble(Ask + tp*Pip, Digits);
         double slPrice = NormalizeDouble(Ask - sl*Pip, Digits);
         item.SetTpPrice(tpPrice);
         item.SetSlPrice(slPrice);
      }
      if(leaveOpType == OP_SELL){
         int tp = item.GetTP();
         int sl = item.GetSL();
         double Pip = oTrade.GetPip();
         double tpPrice = NormalizeDouble(Bid - tp*Pip, Digits);
         double slPrice = NormalizeDouble(Bid + sl*Pip, Digits);
         item.SetTpPrice(tpPrice);
         item.SetSlPrice(slPrice);
      }
      return true;
   }else{
      return false;
   }
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
   //int baseHD = item.GetBaseHD();
   //int HD = item.GetHD();
   Print("COrder::TrailingStop ticket=",ticket,";stoploss=",stoploss,";oop=",oop,";Pip=",Pip);
   if(item.GetOpType() == OP_BUY){
      if((stoploss == 0 || stoploss - oop <1*Pip) && Close[1] - oop > 15*Pip && Ask - oop > 15*Pip){
         oTrade.Modify(ticket, oop, NormalizeDouble(oop + 2*Pip, Digits));
      }
      if((stoploss == 0 || stoploss - oop <3*Pip) && Close[1] - oop > 25*Pip && Ask - oop > 25*Pip){
         oTrade.Modify(ticket, oop, NormalizeDouble(oop + 5*Pip, Digits));
      }
      if((stoploss == 0 || stoploss - oop <7*Pip) && Close[1] - oop > 35*Pip && Ask - oop > 35*Pip){
         oTrade.Modify(ticket, oop, NormalizeDouble(oop + 15*Pip, Digits));
      }
      /*
      if(HD >0){
         double profitPips = (Close[1] - oop)/Pip;
         if(baseHD - profitPips<HD){
            item.SetHD(baseHD - profitPips);
         }
      }
      */
   }
   if(item.GetOpType() == OP_SELL){
      if((stoploss == 0 || oop - stoploss <1*Pip) &&  oop - Close[1] > 15*Pip && oop - Bid > 15*Pip){
         oTrade.Modify(ticket, oop, NormalizeDouble(oop - 2*Pip, Digits));
      }
      if((stoploss == 0 || oop - stoploss <3*Pip) &&  oop - Close[1] > 25*Pip && oop - Bid > 25*Pip){
         oTrade.Modify(ticket, oop, NormalizeDouble(oop - 5*Pip, Digits));
      }
      if((stoploss == 0 || oop - stoploss <7*Pip) &&  oop - Close[1] > 35*Pip && oop - Bid > 35*Pip){
         oTrade.Modify(ticket, oop, NormalizeDouble(oop - 15*Pip, Digits));
      }
      /*
      if(HD >0){
         double profitPips = (oop - Close[1])/Pip;
         if(baseHD - profitPips<HD){
            item.SetHD(baseHD - profitPips);
         }
      }
      */
   }
}

bool COrder::Entry(void){
   
   Signal* sr = oSignal.GetEntrySignal();
   //Print("COrder::Entry sr.sign=",sr.sign,";sr.comment=",sr.comment,";sr.unHedg=",sr.unHedg);
   if(sr.sign == OP_BUY){
      if(!UnHedg(sr)){
         Buy(sr);
      }
   }else if(sr.sign == OP_SELL){
      if(!UnHedg(sr)){
         Sell(sr);
      }
   }else{
      return false;
   }
   return true;
}

bool COrder::Buy(Signal &sr){
   if(TotalItems()>=m_IntMaxItems || TotalItemsActive()>=m_IntMaxActiveItems){
      return false;
   }
   if(isActiveStrategy(sr.sign, sr.strategy)){
      return false;
   }
   //TODO ADD Filter buy
   int t = 0;
   double oop;
   t = oTrade.Buy(m_Lots, 0, 0, sr.comment);
   if(t != 0){
      if(OrderSelect(t, SELECT_BY_TICKET)==true){
         oop = OrderOpenPrice();
      }
      oDictionary.AddObject(t, new CItems(t, m_Lots, sr.intTP,sr.intSL, sr.intHD, sr.strategy, oop, OP_BUY));
      return true;
   }else{
      return false;
   }
}

bool COrder::Sell(Signal &sr){
   if(TotalItems()>=m_IntMaxItems || TotalItemsActive()>=m_IntMaxActiveItems){
      return false;
   }
   if(isActiveStrategy(sr.sign, sr.strategy)){
      return false;
   }
   //TODO ADD Filter sell
   int t = 0;
   double oop;
   t = oTrade.Sell(m_Lots, 0, 0, sr.comment);
   if(t != 0){
      if(OrderSelect(t, SELECT_BY_TICKET)==true){
         oop = OrderOpenPrice();
      }
      oDictionary.AddObject(t, new CItems(t, m_Lots, sr.intTP,sr.intSL, sr.intHD, sr.strategy, oop, OP_SELL));
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
//Strategy is alredy in Activeitems
bool COrder::isActiveStrategy(int opType, string strategy){
   /*
   for(int i=0;i<oArrActiveStrategy.Total();i++){
      oArrActiveStrategy.Delete(i);
   }
   */
   CItems* currItem = oDictionary.GetFirstNode();
   for(int i = 1; (currItem != NULL && CheckPointer(currItem)!=POINTER_INVALID); i++)
   {
      if(currItem.Hedg == 0){
         //oArrActiveStrategy.Add(currItem.GetEntryStrategy());
         if(opType == currItem.GetOpType() && strategy == currItem.GetEntryStrategy()){
            return true;
         }
      }
      currItem = oDictionary.GetNextNode();
   }
   /*
   for(int i=0;i<oArrActiveStrategy.Total();i++){
      if(strategy == oArrActiveStrategy.At(i)){
         return true;
      }
   }
   */
   return false;
}



