USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[CONSIGNMENT_CALC_DEFAULT_GET]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SO_ID, SO_NAME
	FROM dbo.SaleObjectTable
	WHERE SO_ID = 2
END

