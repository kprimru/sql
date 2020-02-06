USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_TYPES_FOR_COMPLECT] 
AS
BEGIN
	SET NOCOUNT ON

	SELECT DistrTypeID, DistrTypeName, DistrTypeName AS DistrTypeShortName
	FROM dbo.DistrTypeTable
    WHERE DistrTypeName IN ('лок', 'сеть', 'ОВК-Ф','ОВМ-Ф(1;2)')
	ORDER BY DistrTypeOrder

	--SELECT NT_SHORT, NT_ID, [NT_VMI_SHORT]
	--FROM din.NetType
	--WHERE 
    --     [NT_TECH] IN (0,1,10,11)
	--	  AND (NT_SHORT IN ('лок', 'ОВК-Ф','ОВМ-Ф (1;2)'))	
	--  ORDER BY NT_SHORT           
END
