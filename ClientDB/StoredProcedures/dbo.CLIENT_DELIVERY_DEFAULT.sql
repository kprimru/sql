USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_DELIVERY_DEFAULT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT TOP 1 EMAIL
	FROM dbo.ClientDelivery
	WHERE ID_DELIVERY = @ID AND @ID = '25eeb199-a6da-e511-9d3c-0007e92aafc5'
	ORDER BY UPD_DATE DESC
END
