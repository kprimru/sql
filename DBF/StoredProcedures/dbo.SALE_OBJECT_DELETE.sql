USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:			������� �������/������ ��������
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[SALE_OBJECT_DELETE]
	@soid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE 
	FROM dbo.SaleObjectTable
	WHERE SO_ID = @soid
END

