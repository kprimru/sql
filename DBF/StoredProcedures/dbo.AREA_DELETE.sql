USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:	  */

CREATE PROCEDURE [dbo].[AREA_DELETE] 
	@areaid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.AreaTable 
	WHERE AR_ID = @areaid

	SET NOCOUNT OFF
END