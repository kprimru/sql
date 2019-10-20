USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_TYPE_RECALCULATE]
	@Client_IDs	VarChar(Max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Clients Table
	(
		Id		Int		NOT NULL	Primary Key Clustered
	);
	
	INSERT INTO @Clients
	SELECT DISTINCT Item
	FROM dbo.GET_TABLE_FROM_LIST(@Client_IDs, ',');
	
	UPDATE C
	SET ClientTypeId = T.ClientTypeId
	FROM dbo.ClientTable	C
	INNER JOIN @Clients		U	ON C.ClientId = U.Id
	OUTER APPLY
	(
		SELECT R.ClientTypeId
		FROM dbo.ClientTypeAllView		T
		INNER JOIN dbo.ClientTypeTable	R ON R.ClientTypeName = T.CATEGORY
		WHERE T.ClientId = C.ClientId
	) T
END