//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "structs.mqh";

class CMa
{  
   private:
      
      int passM5 = 0;
      string crossTypeM5 = "none"; //up down
      
      int passH1 = 0;
      string crossTypeH1 = "none"; //up down
      
      datetime m_EntrySignalM5Time;
      datetime m_EntrySignalH1Time;
      datetime m_ExitSignalM5Time;
      datetime m_ExitSignalH1Time;
      
      datetime m_FillDataM5Time;
      datetime m_FillDataH1Time;
      
      double m_Ma10M5[20];
      double m_Ma30M5[20];
      double m_Stoch100M5[20];
      
      double m_Ma10H1[20];
      double m_Ma30H1[20];
      double m_Stoch100H1[20];
     
      void FillData(int tf, datetime currDt);
      
      
   public:
   
      CStoch(){};
      Signal* EntrySignalM5(void);
      Signal* EntrySignalH1(void);
      
      Signal* ExitSignalM5(void);
      Signal* ExitSignalH1(void);
      
};

void CMa::FillData(int tf, datetime currDt)
{
   int i;
   
   if(tf == PERIOD_M5){
      if(m_FillDataM5Time == currDt){
      
      }else{
         m_FillDataM5Time = currDt;
         for(i=0;i<20;i++){ 
            m_Ma10M5 = iMA(NULL,PERIOD_M5,10,0,MODE_SMA,PRICE_CLOSE,i);
            m_Ma30M5 = iMA(NULL,PERIOD_M5,30,0,MODE_SMA,PRICE_CLOSE,i);
            //m_Stoch14M5[i]  = iStochastic(NULL, PERIOD_M5, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            m_Stoch100M5[i] = iStochastic(NULL, PERIOD_M5, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         }
      }
   }
   if(tf == PERIOD_H1){
      if(m_FillDataH1Time == currDt){
      
      }else{
         m_FillDataH1Time = currDt;
         for(i=0;i<20;i++){
            m_Ma10H1 = iMA(NULL,PERIOD_H1,10,0,MODE_SMA,PRICE_CLOSE,i);
            m_Ma30H1 = iMA(NULL,PERIOD_H1,30,0,MODE_SMA,PRICE_CLOSE,i);
            //m_Stoch14H1[i]  = iStochastic(NULL, PERIOD_H1, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            m_Stoch100H1[i] = iStochastic(NULL, PERIOD_H1, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         }
      }
   }
   
}

Signal* CMa::EntrySignalM5(void)
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
      passM5 += 1;
      if(m_Ma10M5[1] > m_Ma30M5[1] && m_Ma10M5[2] < m_Ma30M5[2]){
         crossTypeM5 = "up";
         passM5 = 0;
      }
      if(m_Ma10M5[1] < m_Ma30M5[1] && m_Ma10M5[2] > m_Ma30M5[2]){
         crossTypeM5 = "down";
         passM5 = 0;
      }
      if(crossTypeM5 == "up" && passM5<20 && m_Stoch100M5[1]>50){
         sr.sign     = OP_BUY;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "CMaM5";
         sr.comment  = "CMaM5";
         
         crossTypeM5 = "none";
         passM5  = 0;
      }
      if(crossTypeM5 == "down" && passM5<20 && m_Stoch100M5[1]<50){
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "CMaM5";
         sr.comment  = "CMaM5";
         
         crossTypeM5 = "none";
         passM5  = 0;
      }
   }
   
   return sr;
}

Signal* CMa::EntrySignalH1(void)
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
      passH1 += 1;
      if(m_Ma10H1[1] > m_Ma30H1[1] && m_Ma10H1[2] < m_Ma30H1[2]){
         crossTypeH1 = "up";
         passH1 = 0;
      }
      if(m_Ma10H1[1] < m_Ma30H1[1] && m_Ma10H1[2] > m_Ma30H1[2]){
         crossTypeH1 = "down";
         passH1 = 0;
      }
      if(crossTypeH1 == "up" && passH1<12 && m_Stoch100H1[1]>50){
         sr.sign     = OP_BUY;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "CMaH1";
         sr.comment  = "CMaH1";
         
         crossTypeH1 = "none";
         passH1  = 0;
      }
      if(crossTypeH1 == "down" && passH1<12 && m_Stoch100H1[1]<50){
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "CMaH1";
         sr.comment  = "CMaH1";
         
         crossTypeH1 = "none";
         passH1  = 0;
      }
   }
   return sr;
}

Signal* CMa::ExitSignalM5(void){
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
      
      if(m_Ma10M5[1] > m_Ma30M5[1] && m_Ma10M5[2] < m_Ma30M5[2]){
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "ExitSignalM5";
         sr.comment  = "ExitSignalM5";
      }
      if(m_Ma10M5[1] < m_Ma30M5[1] && m_Ma10M5[2] > m_Ma30M5[2]){
            sr.sign     = OP_BUY;
            sr.Level    = 1;
            sr.unHedg   = false;
            sr.strategy = "ExitSignalM5";
            sr.comment  = "ExitSignalM5";
      }
   }
   return sr;
}

Signal* CMa::ExitSignalH1(void){
   
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
      
      if(m_Ma10H1[1] > m_Ma30H1[1] && m_Ma10H1[2] < m_Ma30H1[2]){
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "ExitSignalH1";
         sr.comment  = "ExitSignalH1";
      }
      if(m_Ma10H1[1] < m_Ma30H1[1] && m_Ma10H1[2] > m_Ma30H1[2]){
            sr.sign     = OP_BUY;
            sr.Level    = 1;
            sr.unHedg   = false;
            sr.strategy = "ExitSignalH1";
            sr.comment  = "ExitSignalH1";
      }
   }
   return sr;
}
