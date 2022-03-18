USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ODD_DIN_FILTER]
	@DISTR		INT				    = NULL,
	@SYS		NVARCHAR(10)	    = NULL,
	@ACTIVE		BIT				    = NULL,
	@Manager    UniqueIdentifier    = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY

		SELECT
			R.[HostId],
			R.[DistrNumber],
			R.[CompNumber],
			R.[DistrStr],
			RegisterDate,
			DS_INDEX,
			RPR_OPER,
			RPR_DATE,
			PS.[Password],
			O.[Company_Id],
			C.[Name],
			C.[Number],
			M.[Manager_Id],
			OP.SHORT
		FROM [ClientDB].[Reg].[RegNodeSearchView] AS R  WITH(NOEXPAND)
		OUTER APPLY
		(
			SELECT TOP (1) P.RPR_OPER, P.RPR_DATE
			FROM [ClientDB].[dbo].[RegProtocol] AS P
			WHERE P.RPR_ID_HOST = R.HostId
				AND P.RPR_DISTR = R.DistrNumber
				AND P.RPR_COMP = R.CompNumber
				AND RPR_OPER LIKE 'Изменен email%'
			ORDER BY RPR_DATE DESC
		) AS P
		OUTER APPLY
		(
			SELECT TOP (1) PS.[Password]
			FROM [ClientDB].[Queue].[Online Passwords] AS PS
			WHERE PS.[Login] = Cast(R.[DistrNumber] AS VarChar(100))
				AND R.[HostID] = 1
			ORDER BY [CreateDateTime] DESC
		) AS PS
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
		OUTER APPLY
		(
			SELECT TOP (1) M.[Manager_Id]
			FROM [Client].[ManagerOdd] M
			WHERE M.[Host_Id] = R.[HostId]
				AND M.[Distr] = R.[DistrNumber]
				AND M.[Comp] = R.[CompNumber]
			ORDER BY M.[UpdDate] DESC
		) AS M
		LEFT JOIN Personal.OfficePersonal AS OP ON OP.ID = M.Manager_Id
		WHERE	R.SST_SHORT = 'ОДД'
			AND NT_SHORT = 'ОВП' --?
			AND (CAST(DistrNumber AS NVARCHAR) LIKE '%'+CAST(@DISTR AS NVARCHAR)+'%' OR @DISTR IS NULL)
			AND (SystemShortName LIKE '%'+@SYS+'%' OR @SYS IS NULL)
			AND (DS_INDEX = @ACTIVE OR @ACTIVE IS NULL)
			AND (M.Manager_Id = @Manager OR @Manager IS NULL)
		ORDER BY
			CASE WHEN M.Manager_Id IS NULL THEN 1 ELSE 0 END,
			OP.SHORT,
			DS_INDEX,
			SystemShortName,
			DistrNumber,
			CompNumber;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[ODD_DIN_FILTER] TO rl_odd_din_r;
GO
