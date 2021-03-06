USE [CEMS-DR]
GO
/****** Object:  StoredProcedure [dbo].[CronProc_ConSump]    Script Date: 2020-05-01 오후 12:01:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*           
by Hun Kim           
lately update 2018-08-07           
lately update 2018-08-11       
lately update 2018-08-13  - insert 구문 조건 추가        
lately update 2018-09-08  - 이관      
lately update 2018-09-17  - 월별 데이터 축적       
lately update 2018-09-19  - 월별 데이터 축적      
lately update 2018-09-20  - insert 수정     
lately update 2018-09-21  - 년도별 데이터 축적     
*/     
ALTER procedure [dbo].[CronProc_ConSump]     
 (     
 /*변수 정의*/     
 @equip_id varchar(50),     
 @mmindexparam int,     
 @YYYYMMDDHH varchar(50),     
 @value float     
 )     
            
as     
               
if(@mmindexparam % 3 != 0)begin     
 RETURN ;     
end     
               
else begin     
               
 declare @temp int     
           
 declare @totalsum float     
 set @totalsum =0     
               
 declare @div1 float     
 set @div1 = 0.0     
               
 declare @div2 float     
 set @div2 = 0.0     
           
 /*시분초*/     
 declare @nowdate varchar(30)     
 select @nowdate = CONVERT(varchar,getdate(),20)     
                
 /*년월일*/     
 declare @getdate varchar(30)     
 select @getdate = convert(varchar,getdate(),23)     
      
 /*해당월의 첫날*/     
 declare @initday varchar(30)     
 select @initday = DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)     
    
/*해당년도의 첫날*/    
declare @initYYYY varchar(30)    
select @initYYYY = convert(varchar(10), DATEADD(yy, DATEDIFF(yy,0,getdate()), 0),23)       
     
          
                  
 if (@mmindexparam %3 = 0 )begin     
        
 set @temp = @mmindexparam / 3     
 select @div1 = Value_5min from Electricity_consumption_5min where equip_Id = @equip_id and mmIndex = (@mmindexparam - 2)  and YYYYMMDDHH = @YYYYMMDDHH    
 select @div2 = Value_5min from Electricity_consumption_5min where equip_Id = @equip_id and mmIndex = (@mmindexparam - 1)  and YYYYMMDDHH = @YYYYMMDDHH    
 set @totalsum = @div1 + @div2 + @value     
 print 'test15min'     
       
   declare @15equip_Id varchar(500)     
   select Top 1 @15equip_Id = ( select COUNT(*) from Electricity_consumption_15min where equip_Id = @equip_id and YYYYMMDDHH = @YYYYMMDDHH and mmIndex = @temp)    
   if (@15equip_Id < 1)     
   begin     
   insert into dbo.Electricity_consumption_15min(equip_Id,Value_15min,YYYYMMDDHH,NowDate,mmIndex) values (@equip_id,@totalsum,@YYYYMMDDHH,@nowdate,@temp)    
   end     
 set @div1 =0     
 set @div2 =0     
 set @totalsum = 0     
 set @temp = 0     
 end     
         
         
 if(@mmindexparam % 6 =0) begin     
 print 'test30min'     
 set @temp = @mmindexparam / 6     
 select @div1 = Value_15min from Electricity_consumption_15min where equip_Id = @equip_id and mmIndex = ( @mmindexparam /3 -1)  and YYYYMMDDHH = @YYYYMMDDHH    
 select @div2 = Value_15min from Electricity_consumption_15min where equip_Id = @equip_id and mmIndex = ( @mmindexparam /3 )   and YYYYMMDDHH = @YYYYMMDDHH    
 set @totalsum = @div1 + @div2     
  print @totalsum     
   declare @30equip_Id varchar(500)     
   select Top 1 @30equip_Id = (select COUNT(*) from Electricity_consumption_30min where equip_Id = @equip_id and YYYYMMDDHH = @YYYYMMDDHH and mmIndex = @temp)    
   if (@30equip_Id <1)     
   begin     
  insert into dbo.Electricity_consumption_30min(equip_Id,Value_30min,YYYYMMDDHH,NowDate,mmIndex) values (@equip_id,@totalsum,@YYYYMMDDHH,@nowdate,@temp)    
  end     
 set @div1 =0     
 set @div2 =0     
 set @totalsum = 0     
 set @temp = 0     
 end     
           
           
           
 if(@mmindexparam % 12 =0) begin     
  print 'test60min'     
 set @temp = @mmindexparam / 12     
 select @div1 = Value_30min from dbo.Electricity_consumption_30min where equip_Id = @equip_id and mmIndex = (@mmindexparam /6  -1)  and YYYYMMDDHH = @YYYYMMDDHH    
 select @div2 = Value_30min from dbo.Electricity_consumption_30min where equip_Id = @equip_id and mmIndex = (@mmindexparam / 6 )    and YYYYMMDDHH = @YYYYMMDDHH    
 set @totalsum = @div1 + @div2     
   
       
   declare @60equip_Id varchar(500)     
   select Top 1 @60equip_Id = (select COUNT(*) from Electricity_consumption_60min where equip_Id = @equip_id and YYYYMMDDHH = @YYYYMMDDHH and mmIndex = @temp)    
   if (@60equip_Id <1)     
   begin     
  insert into dbo.Electricity_consumption_60min(equip_Id,Value_60min,YYYYMMDDHH,NowDate,mmIndex) values (@equip_id,@totalsum,@YYYYMMDDHH,@nowdate,@temp)    
  end     
 set @div1 =0     
 set @div2 =0     
 set @totalsum = 0     
 set @temp = 0     
 end     
           
       
  if(@mmindexparam = 288 ) begin     
  print 'test1day'     
  declare @tempequip varchar(50)     
  declare @tempmmIndex int     
  declare @tempYYYYMMDDHH varchar(50)     
  declare @tempvalue_60min float     
               
declare data_point cursor for select equip_Id,mmIndex,YYYYMMDDHH,Value_60min from dbo.Electricity_consumption_60min where equip_Id = @equip_id and YYYYMMDDHH = @YYYYMMDDHH order by mmIndex    
open data_point     
           
fetch next from data_point into @tempequip ,@tempmmIndex, @tempYYYYMMDDHH, @tempvalue_60min     
while @@FETCH_STATUS = 0     
begin     
set @totalsum = @totalsum + @tempvalue_60min     
            
           
 fetch next from data_point into @tempequip ,@tempmmIndex, @tempYYYYMMDDHH, @tempvalue_60min     
   end     
  close data_point  deallocate data_point     
   declare @dayequip_Id varchar(500)     
  select top 1 @dayequip_Id = (select count(*) from Electricity_consumption_day where equip_Id = @equip_id and  YYYYMMDDHH = @YYYYMMDDHH)    
    if(@dayequip_Id<1)     
    begin     
  insert into dbo.Electricity_consumption_day(equip_Id,YYYYMMDDHH,Value_1day,NowDate) values (@equip_id,@YYYYMMDDHH,@totalsum,@nowdate)    
  end     
   set @totalsum = 0     
   end     
      
    
    
 if(@mmindexparam = 1 and  @YYYYMMDDHH = @initday)begin     
 print 'month'     
  declare @daytempequip varchar(50)     
  declare @daytempmmIndex int     
  declare @daytempYYYYMMDDHH varchar(50)     
  declare @daytempvalue_1day float     
    
  declare @partMM varchar(10)     
  select @partMM=  DATEPART(MM,DATEADD(mm, DATEDIFF(mm,0,getdate()) - 1, 0))     
    
  declare @partYYYY varchar(10)    
  select @partYYYY = YEAR(GETDATE())     
    
    
  declare @monthbegin varchar(30)     
  declare @monthend varchar(30)     
      
  select @monthbegin = CONVERT(varchar(10),(  select DATEADD(mm, DATEDIFF(mm,0,getdate()) - 1, 0)   ),23 )     
  select @monthend =  CONVERT(varchar(10),(select dateadd(ms,-3,DATEADD(mm, DATEDIFF(mm,0,getdate()  ), 0))),23 )     
    
  declare data_point2 cursor for select equip_Id,YYYYMMDDHH,Value_1day from dbo.Electricity_consumption_day where equip_Id = @equip_id and YYYYMMDDHH >= @monthbegin and YYYYMMDDHH <= @monthend order by YYYYMMDDHH    
  open data_point2     
    
  fetch next from data_point2 into @daytempequip, @daytempYYYYMMDDHH, @daytempvalue_1day     
  while @@FETCH_STATUS =0     
  begin     
  set @totalsum = @totalsum + @daytempvalue_1day     
    
  fetch next from data_point2 into @daytempequip, @daytempYYYYMMDDHH, @daytempvalue_1day     
  end    
  close data_point2 deallocate data_point2     
    
  declare @monthequip varchar(30)     
  select top 1 @monthequip = (select count(*) from Electricity_consumption_month where equip_Id = @equip_id )    
  if(@monthequip<1)     
  begin     
  insert into dbo.Electricity_consumption_month(equip_Id,YYYYMMDDHH,Value_month,NowDate,YYYY) values (@equip_id,@partMM,@totalsum,@nowdate,@partYYYY)    
  end     
     
  set @totalsum = 0      
  end     
    
 if(@YYYYMMDDHH = @initYYYY)    
 begin     
 declare @monthtempequip varchar(10)    
 declare @monthtempmmindex int    
 declare @monthtempYYYYMMDDHH varchar(30)    
 declare @monthtempvalue_month float     
    
 declare @partpastYYYY varchar(10)    
 select @partpastYYYY = YEAR(GETDATE()) -1    
    
 declare data_point3 cursor for select equip_Id,Value_month,YYYYMMDDHH,YYYY from dbo.Electricity_consumption_month where equip_Id = @equip_id and YYYY = @partpastYYYY     
 open data_point3    
    
 fetch next from data_point3 into @monthtempequip,@monthtempvalue_month,@monthtempYYYYMMDDHH,@monthtempmmindex    
while @@FETCH_STATUS = 0    
begin     
set @totalsum = @totalsum + @monthtempvalue_month    
    
 fetch next from data_point3 into @monthtempequip,@monthtempvalue_month,@monthtempYYYYMMDDHH,@monthtempmmindex    
 end    
 close data_point3 deallocate data_point3    
    
 declare @yearequip varchar(30)     
  select top 1 @yearequip = (select count(*) from Electricity_consumption_year where equip_Id = @equip_id )    
  if(@yearequip<1)     
  begin     
  insert into dbo.Electricity_consumption_year(equip_Id,YYYYMMDDHH,Value_year,NowDate) values (@equip_id,@partpastYYYY,@totalsum,@nowdate)    
  end     
     
  set @totalsum = 0      
end       
      
      
      
       
end  /*init begin end*/    