USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[NamedSetItemsSelect] 
(	
	@REF_NAME	NVARCHAR(128),
	@SET_NAME	NVARCHAR(128)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT
		SetItem
	FROM
		dbo.NamedSetsItems
	WHERE
		SetId=(	SELECT SetId
				FROM dbo.NamedSets
				WHERE RefName=@REF_NAME AND SetName=@SET_NAME
				)
)