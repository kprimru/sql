USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ODD_DIN_FILTER]
	@DISTR		INT				=	NULL,
	@SYS		NVARCHAR(10)	=	NULL,
	@ACTIVE		BIT				=	NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		R.[HostId],
		R.[DistrNumber],
		R.[CompNumber],
		R.[DistrStr],
		RegisterDate,
		DS_INDEX,
		RPR_OPER,
		O.[Company_Id],
		C.[Name],
		C.[Number]
	FROM [PC275-SQL\ALPHA].[ClientDB].[Reg].[RegNodeSearchView] AS R  WITH(NOEXPAND)
	OUTER APPLY
	(
		SELECT TOP (1) P.RPR_OPER
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[RegProtocol] AS P
		WHERE P.RPR_ID_HOST = R.HostId
			AND P.RPR_DISTR = R.DistrNumber
			AND P.RPR_COMP = R.CompNumber
			AND RPR_OPER LIKE 'Изменен email%'
		ORDER BY RPR_DATE DESC
	) AS P
	OUTER APPLY
	(
		SELECT TOP (1) O.[Company_Id]
		FROM [Client].[CompanyOdd] O
		WHERE O.[Host_Id] = R.[HostId]
			AND O.[Distr] = R.[DistrNumber]
			AND O.[Comp] = R.[CompNumber]
		ORDER BY O.[UpdDate] DESC
	) AS O
	LEFT JOIN Client.Company C ON C.[Id] = O.[Company_Id]
	WHERE	R.SST_SHORT = 'ОДД'
		AND NT_SHORT = 'ОВП' --?
		AND (CAST(DistrNumber AS NVARCHAR) LIKE '%'+CAST(@DISTR AS NVARCHAR)+'%' OR @DISTR IS NULL)
		AND (SystemShortName LIKE '%'+@SYS+'%' OR @SYS IS NULL)
		AND (DS_INDEX = @ACTIVE OR @ACTIVE IS NULL)
	ORDER BY DS_INDEX, SystemShortName
END
