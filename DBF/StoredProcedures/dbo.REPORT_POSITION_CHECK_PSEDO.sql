USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[REPORT_POSITION_CHECK_PSEDO] 
	@positionreportpsedo VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT RP_ID
	FROM dbo.ReportPositionTable
	WHERE RP_PSEDO = @positionreportpsedo

	SET NOCOUNT OFF
END






