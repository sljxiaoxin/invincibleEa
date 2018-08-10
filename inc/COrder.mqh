//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015."
#property link      "http://www.mql5.com"

class COrder
{
   private:
      
      double m_Lots;
      double m_IntTP;
      double m_IntSL;
      bool   m_AutoLots;
      CTrade* oTrade;
      CFilter* oFilter;

   public:
      COrder(){
         oTrade = new CTrade();
         oFilter = new CFilter();
      };
      
      void Init(double lots, int tp, int sl, bool autolots, bool filter);
      int  CheckOpen(Signal sr);
      bool Buy(Signal sr);
      bool Sell(Signal sr);
      double ItemProfit(CItems* item);
      int  TotalItems(void);
      bool CloseItem(CItems* item);
      bool isItemAllClosed(CItems* item);
};

void COrder::Init(double lots, double tp, double sl, bool autolots, bool filter){
   m_Lots = lots;
   m_IntTP = tp;
   m_IntSL = sl;
   m_AutoLots = autolots;
   oFilter.setFilter(filter);
}

int COrder::CheckOpen(Signal sr){
   //1、check total order num
   //2、filter
   //3、make AutoLots
}

