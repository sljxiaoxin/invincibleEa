//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "structs.mqh";

class CStoch
{  
   private:
      datetime m_EntrySignalM5Time;
      datetime m_EntrySignalH1Time;
      datetime m_ExitSignalM5Time;
      datetime m_ExitSignalH1Time;
      
      datetime m_FillDataM5Time;
      datetime m_FillDataH1Time;
      
      double m_Stoch14M5[20];
      double m_Stoch100M5[20];
      double m_Stoch14H1[20];
      double m_Stoch100H1[20];
     
      void FillData(int tf, datetime currDt);
      
      
   public:
   
      CStoch(){};
      Signal* EntrySignalM5(void);
      Signal* EntrySignalH1(void);
      
      Signal* ExitSignalM5(void);
      Signal* ExitSignalH1(void);
      
      int   EntrySignalM5_Buy(void);
      int   EntrySignalM5_Sell(void);
      int   EntrySignalH1_Buy(void);
      int   EntrySignalH1_Sell(void);
};

void CStoch::FillData(int tf, datetime currDt)
{
   int i;
   
   if(tf == PERIOD_M5){
      if(m_FillDataM5Time == currDt){
      
      }else{
         m_FillDataM5Time = currDt;
         for(i=0;i<20;i++){ 
            m_Stoch14M5[i]  = iStochastic(NULL, PERIOD_M5, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            m_Stoch100M5[i] = iStochastic(NULL, PERIOD_M5, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         }
      }
   }
   if(tf == PERIOD_H1){
      if(m_FillDataH1Time == currDt){
      
      }else{
         m_FillDataH1Time = currDt;
         for(i=0;i<20;i++){
            m_Stoch14H1[i]  = iStochastic(NULL, PERIOD_H1, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            m_Stoch100H1[i] = iStochastic(NULL, PERIOD_H1, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         }
      }
   }
   
}

Signal* CStoch::EntrySignalM5(void)
{
   Signal* sr = new Signal();
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_EntrySignalM5Time == iTime(NULL,PERIOD_M5,0)){
      
   }else{
      m_EntrySignalM5Time = iTime(NULL,PERIOD_M5,0);
      FillData(PERIOD_M5, m_EntrySignalM5Time);
      int level = EntrySignalM5_Buy();
      if(level >-1){
         sr.sign     = OP_BUY;
         sr.Level    = level;
         sr.unHedg   = false;
         sr.strategy = "CStochM5";
         sr.comment  = "CStochM5";
      }else{
         level = EntrySignalM5_Sell();
         if(level > -1){
            sr.sign     = OP_SELL;
            sr.Level    = level;
            sr.unHedg   = false;
            sr.strategy = "CStochM5";
            sr.comment  = "CStochM5";
         }
      }
   }
   return sr;
}

Signal* CStoch::EntrySignalH1(void)
{  
   Signal* sr = new Signal();
   //sr = {-1,-1,false,"",""};
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_EntrySignalH1Time == iTime(NULL,PERIOD_H1,0)){
      
   }else{
      m_EntrySignalH1Time = iTime(NULL,PERIOD_H1,0);
      FillData(PERIOD_H1, m_EntrySignalH1Time);
      int level = EntrySignalH1_Buy();
      if(level >-1){
         sr.sign     = OP_BUY;
         sr.Level    = level;
         sr.unHedg   = true;
         sr.strategy = "CStochH1";
         sr.comment  = "CStochH1";
      }else{
         level = EntrySignalH1_Sell();
         if(level > -1){
            sr.sign     = OP_SELL;
            sr.Level    = level;
            sr.unHedg   = true;
            sr.strategy = "CStochH1";
            sr.comment  = "CStochH1";
         }
      }
   }
   return sr;
}

Signal* CStoch::ExitSignalM5(void){
   Signal* sr = new Signal();
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_ExitSignalM5Time == iTime(NULL,PERIOD_M5,0)){
      
   }else{
      m_ExitSignalM5Time = iTime(NULL,PERIOD_M5,0);
      FillData(PERIOD_M5, m_ExitSignalM5Time);
      int level = EntrySignalM5_Buy();
      if(level >-1){
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "ExitSignalM5";
         sr.comment  = "ExitSignalM5";
      }else{
         level = EntrySignalM5_Sell();
         if(level >-1){
            sr.sign     = OP_BUY;
            sr.Level    = 1;
            sr.unHedg   = false;
            sr.strategy = "ExitSignalM5";
            sr.comment  = "ExitSignalM5";
         }
      }
   }
   return sr;
}

Signal* CStoch::ExitSignalH1(void){
   
   Signal* sr = new Signal();
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_ExitSignalH1Time == iTime(NULL,PERIOD_H1,0)){
      
   }else{
      m_ExitSignalH1Time = iTime(NULL,PERIOD_H1,0);
      FillData(PERIOD_H1, m_ExitSignalH1Time);
      int level = EntrySignalH1_Buy();
      if(level >-1){
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "ExitSignalH1";
         sr.comment  = "ExitSignalH1";
      }else{
         level = EntrySignalH1_Sell();
         if(level >-1){
            sr.sign     = OP_BUY;
            sr.Level    = 1;
            sr.unHedg   = false;
            sr.strategy = "ExitSignalH1";
            sr.comment  = "ExitSignalH1";
         }
      }
   }
   return sr;
}

////////////////////////////////////////////////////////////////
int CStoch::EntrySignalM5_Buy(void){
   int level = -1;
   if(m_Stoch14M5[1] > m_Stoch100M5[1] && m_Stoch14M5[2] < m_Stoch100M5[2] && m_Stoch14M5[2]<18){
      level = 2;
   }
   return level;
}

int CStoch::EntrySignalM5_Sell(void){
   int level = -1;
   if(m_Stoch14M5[1] < m_Stoch100M5[1] && m_Stoch14M5[2] > m_Stoch100M5[2] && m_Stoch14M5[2]>82){
      level = 2;
   }
   return level;
}

int CStoch::EntrySignalH1_Buy(void){
   int level = -1;
   if(m_Stoch14H1[1] > m_Stoch100H1[1] && m_Stoch14H1[2] < m_Stoch100H1[2] && m_Stoch14H1[2]<18){
      level = 2;
   }
   return level;
}

int CStoch::EntrySignalH1_Sell(void){
   int level = -1;
   if(m_Stoch14H1[1] < m_Stoch100H1[1] && m_Stoch14H1[2] > m_Stoch100H1[2] && m_Stoch14H1[2]<18){
      level = 2;
   }
   return level;
}