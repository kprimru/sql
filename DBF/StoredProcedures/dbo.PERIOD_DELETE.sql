USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 15.10.2008
��������:	  ������� ������ � ��������� 
               ����� �� �����������
*/

CREATE PROCEDURE [dbo].[PERIOD_DELETE] 
	@periodid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.PeriodTable 
	WHERE PR_ID = @periodid
	
	SET	NOCOUNT OFF
END



