USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SEND_ADM_PK_KRAY_CITY_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SEND_ADM_PK_KRAY_CITY_REPORT]  AS SELECT 1')
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[SEND_ADM_PK_KRAY_CITY_REPORT]
AS
BEGIN
SET NOCOUNT ON;

    DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

Declare @Scode INT
Declare @Ccode INT
Declare @Cday smalldatetime
Declare @mindate	SMALLDATETIME

SET  @mindate = DATEADD(DAY, -1, CONVERT(DATETIME, CONVERT(VARCHAR(20), GETDATE(), 112), 112))

DECLARE @BODY NVARCHAR(MAX)
SET @BODY = ''
/*
SELECT TOP 1
       @Cday  = [CSD_DAY]
      ,@Ccode = [CSD_CODE_CLIENT]
      ,@Scode = [CSD_CODE_SERVER]
  FROM [IPLogs].[dbo].[ClientStatDetail]
WHERE ([CSD_DISTR]=769333)AND(CSD_SYS=1)
order by CSD_DAY DESC


IF (@Ccode <> 0) or ((@Scode<>0)and(@Scode<>70)) or (@Cday < @mindate)
BEGIN
     SET @BODY = @BODY +char(0xD)+char(0xA)+ CONVERT (varchar, @CDAy)+' 769333 ip-errors: '+CONVERT(varchar, @Scode)+' ' +CONVERT(varchar, @Ccode)
END
*/
SELECT TOP 1
       @Cday  = [CSD_DAY]
      ,@Ccode = [CSD_CODE_CLIENT]
      ,@Scode = [CSD_CODE_SERVER]
  FROM [IPLogs].[dbo].[ClientStatDetail]
WHERE ([CSD_DISTR]=863809)AND(CSD_SYS=121)
order by CSD_DAY DESC


IF (@Ccode <> 0) or ((@Scode<>0)and(@Scode<>70)) or (@Cday < @mindate)
BEGIN
     SET @BODY = @BODY +char(0xD)+char(0xA)+ CONVERT (varchar, @CDAy)+' 863809 ip-errors: '+CONVERT(varchar, @Scode)+' ' +CONVERT(varchar, @Ccode)
END

SELECT TOP 1
       @Cday  = [CSD_DAY]
      ,@Ccode = [CSD_CODE_CLIENT]
      ,@Scode = [CSD_CODE_SERVER]
  FROM [IPLogs].[dbo].[ClientStatDetail]
WHERE ([CSD_DISTR]=451765)AND(CSD_SYS=123)
order by CSD_DAY DESC

IF (@Ccode <> 0) or ((@Scode<>0)and(@Scode<>70)) or (@Cday < @mindate)
BEGIN
     SET @BODY = @BODY +char(0xD)+char(0xA)+ CONVERT (varchar, @CDAy)+' 451765 ip-errors: '+CONVERT(varchar, @Scode)+' ' +CONVERT(varchar, @Ccode)

END
--PRINT 'body '+@body+' '+CONVERT (varchar, @CDAy)+' '+CONVERT (varchar, convert(smalldatetime, getdate()))+' '+ CONVERT(VARCHAR, GETDATE(), 112)

SELECT TOP 1
       @Cday  = [CSD_DAY]
      ,@Ccode = [CSD_CODE_CLIENT]
      ,@Scode = [CSD_CODE_SERVER]
  FROM [IPLogs].[dbo].[ClientStatDetail]
WHERE ([CSD_DISTR]=8770)AND(CSD_SYS=16)
order by CSD_DAY DESC

IF (@Ccode <> 0) or ((@Scode<>0)and(@Scode<>70)) or (@Cday < @mindate)
BEGIN
     SET @BODY = @BODY +char(0xD)+char(0xA)+ CONVERT (varchar, @CDAy)+' 8770 ip-errors: '+CONVERT(varchar, @Scode)+' ' +CONVERT(varchar, @Ccode)

END

SELECT TOP 1
       @Cday  = [CSD_DAY]
      ,@Ccode = [CSD_CODE_CLIENT]
      ,@Scode = [CSD_CODE_SERVER]
  FROM [IPLogs].[dbo].[ClientStatDetail]
WHERE ([CSD_DISTR]=6884)AND(CSD_SYS=16)
order by CSD_DAY DESC

IF (@Ccode <> 0) or ((@Scode<>0)and(@Scode<>70)) or (@Cday < @mindate)
BEGIN
     SET @BODY = @BODY +char(0xD)+char(0xA)+ CONVERT (varchar, @CDAy)+' 6884 ip-errors: '+CONVERT(varchar, @Scode)+' ' +CONVERT(varchar, @Ccode)

END

SELECT TOP 1
       @Cday  = [CSD_DAY]
      ,@Ccode = [CSD_CODE_CLIENT]
      ,@Scode = [CSD_CODE_SERVER]
  FROM [IPLogs].[dbo].[ClientStatDetail]
WHERE ([CSD_DISTR]=451755)AND(CSD_SYS=123)
order by CSD_DAY DESC

IF (@Ccode <> 0) or ((@Scode<>0)and(@Scode<>70)) or (@Cday < @mindate)
BEGIN
     SET @BODY = @BODY +char(0xD)+char(0xA)+ CONVERT (varchar, @CDAy)+' 451755 ip-errors: '+CONVERT(varchar, @Scode)+' ' +CONVERT(varchar, @Ccode)

END

IF (LEN(@BODY)<2) SET @BODY = 'ip-popolnenie ALL OK '
IF (LEN(@BODY)>1)
BEGIN
	EXEC msdb.dbo.sp_send_dbmail @profile_name = 'SQLMail',
				@recipients = N'blohin@bazis',
				@body = @BODY,
				@subject='Отчет по пополнению администрации края'
END


EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
