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

CREATE PROCEDURE [dbo].[DISTR_GET]  
	@distrid INT = NULL  
AS
BEGIN
	SET NOCOUNT ON

	SELECT DIS_NUM, DIS_COMP_NUM, SYS_ID, SYS_SHORT_NAME, DIS_ACTIVE, DIS_STR
	FROM dbo.DistrView
	WHERE DIS_ID = @distrid

	SET NOCOUNT OFF
END















