USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_TYPE_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ServiceTypeName, ServiceTypeShortName, ServiceTypeVisit, ServiceTypeDefault
	FROM dbo.ServiceTypeTable
	WHERE ServiceTypeID = @ID
END