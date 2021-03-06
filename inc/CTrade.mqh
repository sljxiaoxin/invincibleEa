//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015."
#property link      "http://www.mql5.com"

class CTrade
{
   private:
   
      int    m_Magic;
      int    m_Tries;
      int    m_Slippage;
      double m_Pip;
      bool Errors(int Error);
      
   public:
      
      CTrade(){
         m_Magic = 201808;
         m_Tries = 10;
         m_Slippage = 5;
         if(Digits==2 || Digits==4){
            m_Pip = Point;
         }else if(Digits==3 || Digits==5){
            m_Pip = 10*Point;
         }else if(Digits==6){
            m_Pip = 100*Point;
         }else{
            m_Pip = Point;
         }
      };
      
      int    Total(void);
      int    Buy(double Lot, int SL, int TP, string Comments);
      int    Sell(double Lot, int SL, int TP, string Comments);
      bool   Modify(int ticket, double oop, double sl);
      bool   Close(int ticket);
      double GetPip(void);
      int    GetOrderType(int ticket);
      double GetProfitPips(int ticket);
      double GetOrderStopLoss(int ticket);
      bool   isOrderClosed(int ticket);
};

int CTrade::Total(void){
   int cnt;
   int total = 0;
   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL &&
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==m_Magic) total++;
   }
   return(total);
}

int CTrade::Buy(double Lot, int SL, int TP, string Comments){
   int ticket=-1, 
       err = 0;
   double stopLoss = 0,
          takeProfit = 0;
   if(SL != 0)
   {
      stopLoss   = NormalizeDouble(Bid-SL*m_Pip,Digits);
   }
   
   if(TP != 0)
   {
      takeProfit = NormalizeDouble(Bid+TP*m_Pip,Digits);
   }
   for(int c=0;c<m_Tries;c++)
   {
      ticket = OrderSend(Symbol(),OP_BUY,Lot,Ask,m_Slippage,stopLoss,takeProfit,Comments,m_Magic,0,Green);
      err=GetLastError();
      if(err==0)
      { 
         if(ticket>0) break;
      }
      else
      {
         if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
         {
            Sleep(1000);
            continue;
         }
         else //normal error
         {
            if(ticket>0) break;
         }  
      }
   } 
   return(ticket); 
}

int CTrade::Sell(double Lot, int SL, int TP, string Comments){
   int ticket=-1, 
       err = 0;
   double stopLoss = 0,
          takeProfit = 0;
   if(SL != 0)
   {
      stopLoss   = NormalizeDouble(Ask+SL*m_Pip,Digits);
   }
   
   if(TP != 0)
   {
      takeProfit = NormalizeDouble(Ask-TP*m_Pip,Digits);
   }
   for(int c=0;c<m_Tries;c++)
   {
      ticket = OrderSend(Symbol(),OP_SELL,Lot,Bid,m_Slippage,stopLoss,takeProfit,Comments,m_Magic,0,Red);
      err=GetLastError();
      if(err==0)
      { 
         if(ticket>0) break;
      }
      else
      {
         if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
         {
            Sleep(1000);
            continue;
         }
         else //normal error
         {
            if(ticket>0) break;
         }  
      }
   } 
   return(ticket); 
}

bool CTrade::Modify(int ticket, double oop, double sl){
   bool  Ans = false;         
   if(OrderSelect(ticket,SELECT_BY_TICKET)){
      Ans = OrderModify(ticket, oop, sl, OrderTakeProfit(), 0);
   }
   return(Ans);
}

bool CTrade::Close(int ticket){
   bool  Ans = false;         
   double ClosePrice = 0.0;
   if(OrderSelect(ticket,SELECT_BY_TICKET))
   {
       while(!Ans)    //Trying closing the order until successfuly
       {
            //-----------------------------------------------------------------------
            if ( OrderType() == OP_BUY )
            {
                 ClosePrice = NormalizeDouble(Bid,Digits);
                 Ans        = OrderClose(ticket,OrderLots(),ClosePrice,m_Slippage,Green);
            }     
            if ( OrderType() == OP_SELL )
            {
                 ClosePrice = NormalizeDouble(Ask,Digits);
                 Ans = OrderClose(ticket,OrderLots(),ClosePrice,m_Slippage,Red);
            }               
            //----------------------------------------------------------------------
            if(Ans == false)
            {
                 if ( Errors(GetLastError())==false )// If the error is ritical
                 {
                      return(false);
                 }
            }
       }
   }
   
   return(Ans);
}

bool CTrade::Errors(int Error)
 {
      // Error             // Error number  
   if(Error==0)
      return(false);                      // No Error
   //--------------------------------------------------------------- 3 --
   switch(Error)
     {   // Overcomeable errors:
      case 129:         // Wrong price
      case 135:         // Price changed
         RefreshRates();                  // Renew date
         return(true);                    // Error is overcomable
      case 136:         // No quotes. Waiting for the tick to come
      case 138:         // The price is outdated, need to be refresh
         while(RefreshRates()==false)     // Before new tick
            Sleep(1);                     // Delay in the cycle
         return(true);                    // Error is ovecomable
      case 146:         // The trade sybsystem is busy
         Sleep(500);                      // Simple solution
         RefreshRates();                  // Renew data
         return(true);                    // Error is overcomable
         // Critical errors:
      case 2 :          // Common error
      case 5 :          // Old version of the client terminal
      case 64:          // Account blocked
      case 133:         // Trading is prohibited
      default:          // Other variants
         return(false);                   // Critical error
     }
 }

double CTrade::GetPip(void){
   return m_Pip;
}

int CTrade::GetOrderType(int ticket){
   if(OrderSelect(ticket, SELECT_BY_TICKET)==true){
      return OrderType();
   }
   return -1;
}

double CTrade::GetOrderStopLoss(int ticket){
   if(OrderSelect(ticket, SELECT_BY_TICKET)==true){
      return NormalizeDouble(OrderStopLoss(),Digits);
   }
   return -1;
}

double CTrade::GetProfitPips(int ticket){
   double pips = 0;
    if(OrderSelect(ticket, SELECT_BY_TICKET)==true){
        datetime dtc = OrderCloseTime();
        if(dtc >0){
            //订单已平仓，则返回0
            return pips;
        }
        int TradeType = OrderType();
        double openPrice = OrderOpenPrice();
        if(TradeType == OP_BUY){
            pips = (Ask - openPrice)/GetPip();
        }
        if(TradeType == OP_SELL){
            pips = (openPrice - Bid)/GetPip();
        }
    }
    return pips;
}

bool CTrade::isOrderClosed(int ticket){
   if(OrderSelect(ticket, SELECT_BY_TICKET)==true){
         datetime dtc = OrderCloseTime();
         if(dtc >0){
            return true;
         }else{
            return false;
         }
    }
    return false;
}