USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONTACT_TYPE_SELECT]
	@FILTER NVARCHAR(256) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME
	FROM dbo.ClientContactType
	ORDER BY NAME
END
