//+------------------------------------------------------------------+
//|                                                  CTradeMgr.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015."
#property link      "http://www.mql5.com"

class CItems : public CObject
{
   private:
      int m_Ticket;           //order ticket no
      double m_Oop;           //order open price
      string m_EntryStrategy; //entry Strategy name
      int m_OpType;           //OP_BUY OR OP_SELL
      int m_IntTP;
      int m_IntSL;
      double m_Lots;
      
   public:
      int Hedg;          //hedg ticket no
      CArrayInt *Marti;  //marti no
      CItems(int ticket, double lots, int tp, int sl, string entryStrategy, double oop, int opType){
        
         m_Ticket = ticket;
         m_Lots = lots;
         m_IntTP = tp;
         m_IntSL = sl;
         m_EntryStrategy = entryStrategy;
         m_Oop = oop;
         m_OpType = opType;
         
         Hedg = 0;
         Marti = new CArrayInt;
      }
      int GetTicket(){return m_Ticket;}
      double GetLots(){return m_Lots;}
      int GetTP(){return m_IntTP;}
      int GetSL(){return m_IntSL;}
      double GetOop(){return m_Oop;}
      string GetEntryStrategy(){return m_EntryStrategy;}
      int GetOpType(){return m_OpType;};
};