USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	

/*
�����:		  ������� �������
���� ��������: 15.10.2008
��������:	  ���������� ID ������� 
               � ��������� ���������. 
*/

CREATE PROCEDURE [dbo].[PERIOD_CHECK_DATE] 
	@perioddate SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	SELECT PR_ID
	FROM dbo.PeriodTable
	WHERE PR_DATE = @perioddate

	SET NOCOUNT OFF
END
