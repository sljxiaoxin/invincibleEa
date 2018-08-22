//+------------------------------------------------------------------+
//|                                                  CTradeMgr.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015."
#property link      "http://www.mql5.com"

#include <Arrays\ArrayInt.mqh>
class CItems : public CObject
{
   private:
      int m_Ticket;           //order ticket no
      double m_Oop;           //order open price
      string m_EntryStrategy; //entry Strategy name
      int m_OpType;           //OP_BUY OR OP_SELL
      int m_IntTP;
      double m_TpPrice;
      double m_SlPrice;
      int m_IntSL;
      int m_IntHD;   //hedg
      int m_IntBaseHD;
      double m_Lots;
      
   public:
      int Hedg;          //hedg ticket no
      CArrayInt *Marti;  //marti no
      CItems(int ticket, double lots, int tp,int sl, int hd, string entryStrategy, double oop, int opType){
         m_TpPrice = 0;
         m_SlPrice = 0;
         m_Ticket = ticket;
         m_Lots = lots;
         m_IntTP = tp;
         m_IntSL = sl;
         m_IntHD = hd;
         m_IntBaseHD = hd;
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
      int GetHD(){return m_IntHD;}
      int GetBaseHD(){return m_IntBaseHD;}
      double GetOop(){return m_Oop;}
      string GetEntryStrategy(){return m_EntryStrategy;}
      int GetOpType(){return m_OpType;};
      void SetSL(int sl){m_IntSL = sl;};
      void SetHD(int hd){m_IntHD = hd;};
      void SetTpPrice(double tp){m_TpPrice = tp};
      void SetSlPrice(double sl){m_SlPrice = sl};
      double GetTpPrice(){return m_TpPrice;};
      double GetSlPrice(){return m_SlPrice;};
};