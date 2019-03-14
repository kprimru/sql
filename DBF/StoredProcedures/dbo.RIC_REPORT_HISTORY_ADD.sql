USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	

/*
Автор:			Денисов Алексей
Дата создания:	10.02.2009
Описание:		
*/

CREATE PROCEDURE [dbo].[RIC_REPORT_HISTORY_ADD]
	@periodid SMALLINT
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO dbo.VMIReportHistoryTable
			
	SELECT
	/*		(
				SELECT PR_NAME
				FROM dbo.PeriodTable
				WHERE PR_ID=@periodid
			) AS PERIOD,
	*/
			@periodid,
			VMR_RIC_NUM, VMR_TO_NUM, VMR_TO_NAME,
			VMR_INN, VMR_REGION, VMR_CITY, VMR_ADDR,
			VMR_FIO_1, VMR_JOB_1, VMR_TELS_1,
			VMR_FIO_2, VMR_JOB_2, VMR_TELS_2,
			VMR_FIO_3, VMR_JOB_3, VMR_TELS_3,
			VMR_FIO_4, VMR_JOB_4, VMR_TELS_4,
			VMR_FIO_5, VMR_JOB_5, VMR_TELS_5,
			VMR_SERV, VMR_DISTR, VMR_COMMENT
			FROM dbo.VMIReportTable

	DELETE FROM dbo.VMIReportTable

END

















