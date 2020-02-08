USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Din].[NetTypeOffline]()
RETURNS TABLE AS RETURN
(
	SELECT NT_ID = Cast(SetItem AS SmallInt)
	FROM dbo.NamedSetItemsSelect('Din.NetType', '־פפכאים')
)
