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
      
      int passM15;
      string crossTypeM15; //up down
      
      int passH1;
      string crossTypeH1; //up down
      
      datetime m_EntrySignalM15Time;
      datetime m_EntrySignalH1Time;
      datetime m_ExitSignalM15Time;
      datetime m_ExitSignalH1Time;
      
      datetime m_FillDataM15Time;
      datetime m_FillDataH1Time;
      
      double m_Ma10M15[20];
      double m_Ma30M15[20];
      double m_Stoch100M15[20];
      
      double m_Ma10H1[20];
      double m_Ma30H1[20];
      double m_Stoch100H1[20];
     
      void FillData(int tf, datetime currDt);
      
      
   public:
   
      CMa(){
         passM15 = 0;
         crossTypeM15 = "none"; //up down
         passH1 = 0;
         crossTypeH1 = "none"; //up down
      };
      Signal* EntrySignalM15(void);
      Signal* EntrySignalH1(void);
      
      Signal* ExitSignalM15(void);
      Signal* ExitSignalH1(void);
      
};

void CMa::FillData(int tf, datetime currDt)
{
   int i;
   
   if(tf == PERIOD_M15){
      if(m_FillDataM15Time == currDt){
      
      }else{
         m_FillDataM15Time = currDt;
         for(i=0;i<20;i++){ 
            m_Ma10M15[i] = iMA(NULL,PERIOD_M15,10,0,MODE_SMA,PRICE_CLOSE,i);
            m_Ma30M15[i] = iMA(NULL,PERIOD_M15,30,0,MODE_SMA,PRICE_CLOSE,i);
            //m_Stoch14M5[i]  = iStochastic(NULL, PERIOD_M5, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            m_Stoch100M15[i] = iStochastic(NULL, PERIOD_M15, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         }
      }
   }
   if(tf == PERIOD_H1){
      if(m_FillDataH1Time == currDt){
      
      }else{
         m_FillDataH1Time = currDt;
         for(i=0;i<20;i++){
            m_Ma10H1[i] = iMA(NULL,PERIOD_H1,10,0,MODE_SMA,PRICE_CLOSE,i);
            m_Ma30H1[i] = iMA(NULL,PERIOD_H1,30,0,MODE_SMA,PRICE_CLOSE,i);
            //m_Stoch14H1[i]  = iStochastic(NULL, PERIOD_H1, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            m_Stoch100H1[i] = iStochastic(NULL, PERIOD_H1, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         }
      }
   }
   
}

Signal* CMa::EntrySignalM15(void)
{
   Signal* sr = new Signal();
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_EntrySignalM15Time == iTime(NULL,PERIOD_M15,0)){
      
   }else{
      m_EntrySignalM15Time = iTime(NULL,PERIOD_M15,0);
      FillData(PERIOD_M15, m_EntrySignalM15Time);
      passM15 += 1;
      if(m_Ma10M15[1] > m_Ma30M15[1] && m_Ma10M15[2] < m_Ma30M15[2]){
         crossTypeM15 = "up";
         passM15 = 0;
      }
      if(m_Ma10M15[1] < m_Ma30M15[1] && m_Ma10M15[2] > m_Ma30M15[2]){
         crossTypeM15 = "down";
         passM15 = 0;
      }
      if(crossTypeM15 == "up" && passM15<20 && m_Stoch100M15[1]>48){
         sr.sign     = OP_BUY;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "CMaM15";
         sr.comment  = "CMaM15";
         
         crossTypeM15 = "none";
         passM15  = 0;
      }
      if(crossTypeM15 == "down" && passM15<20 && m_Stoch100M15[1]<52){
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "CMaM15";
         sr.comment  = "CMaM15";
         
         crossTypeM15 = "none";
         passM15  = 0;
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

Signal* CMa::ExitSignalM15(void){
   Signal* sr = new Signal();
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_ExitSignalM15Time == iTime(NULL,PERIOD_M15,0)){
      
   }else{
      m_ExitSignalM15Time = iTime(NULL,PERIOD_M15,0);
      FillData(PERIOD_M15, m_ExitSignalM15Time);
      
      if(m_Ma10M15[1] > m_Ma30M15[1] && m_Stoch100M15[1]>48){
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "ExitSignalM15";
         sr.comment  = "ExitSignalM15";
      }
      if(m_Ma10M15[1] < m_Ma30M15[1] && m_Stoch100M15[1]<52){
            sr.sign     = OP_BUY;
            sr.Level    = 1;
            sr.unHedg   = false;
            sr.strategy = "ExitSignalM15";
            sr.comment  = "ExitSignalM15";
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
