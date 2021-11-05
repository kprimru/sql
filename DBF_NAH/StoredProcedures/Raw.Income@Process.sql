USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Raw].[Income@Process]
    @Organization_Id    SmallInt,
    @InDate             SmallDateTime,
    @Data               VarChar(Max),
    @AutoConvey         Bit = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @IDs Table
    (
        Id          Int Primary Key Clustered,
        Price       Money,
        Date        SmallDateTime,
        Client_Id   Int
    );

    DECLARE @Convey Table
    (
        DIS_ID      Int,
        DIS_STR     VarChar(100),
        ID_PRICE    Money,
        PR_ID       SmallInt,
        PR_DATE     SmallDateTime,
        ID_PREPAY   Bit,
        ID_ACTION   Bit
    );

    DECLARE
        @Id         Int,
        @Date       SmallDateTime,
        @Client_Id  Int,
        @Price      Money;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY
        INSERT INTO dbo.IncomeTable ([IN_ID_ORG], [IN_ID_CLIENT], [IN_DATE], [IN_SUM], [IN_PAY_DATE], [IN_PAY_NUM], [IN_PRIMARY], [Raw_Id])
        OUTPUT inserted.IN_ID INTO @IDs ([Id])
        SELECT @Organization_Id, C.[CL_ID], @InDate, D.[Price], D.[Date], D.[Num], 0, D.[Id]
        FROM dbo.GET_TABLE_FROM_LIST(@Data, ',') AS IDs
        INNER JOIN [Raw].[Incomes:Details] AS D ON D.[Id] = IDs.[Item]
        CROSS APPLY
        (
            SELECT [CL_ID] = D.[Client_Id]
            WHERE D.[Client_Id] IS NOT NULL

            UNION ALL

            SELECT TOP (1)
                C.[CL_ID]
            FROM [dbo].[ClientTable] AS C
            WHERE C.[CL_INN] = D.[Inn]
                AND D.[Client_Id] IS NULL
        ) AS C
        WHERE C.[CL_ID] IS NOT NULL;

        UPDATE I SET
            [Date]      = IT.[IN_DATE],
            [Client_Id] = IT.[IN_ID_CLIENT],
            [Price]     = IT.[IN_SUM]
        FROM @IDs AS I
        INNER JOIN dbo.IncomeTable AS IT ON IT.[IN_ID] = I.[Id]

        SET @Id = 0;

        WHILE (1 = 1) BEGIN
            DELETE FROM @Convey;

            SELECT TOP (1)
                @Id         = I.[Id],
                @Price      = I.[Price],
                @Date       = I.[Date],
                @Client_Id  = I.[Client_Id]
            FROM @IDs AS I
            WHERE I.[Id] > @Id
            ORDER BY
                I.[Id];

            IF @@RowCount < 1
                BREAK;

            INSERT INTO @Convey
            EXEC [dbo].[INCOME_AUTO_CONVEY] @incomeid = @Id;

            IF
                @AutoConvey = 1
                -- сумма в разнесении совпала с суммой платежа (на всякий случай)
                AND
                    (SELECT Sum(ID_PRICE) FROM @Convey) = @Price
                AND
                    (
                        SELECT Sum(ID_PRICE) FROM @Convey
                    ) =
                    (
                        SELECT Sum(BD_TOTAL_PRICE)
                        FROM dbo.BillIXView WITH(NOEXPAND)
                        WHERE BL_ID_CLIENT = @Client_Id
                            AND BL_ID_PERIOD IN
                                (
                                    SELECT PR_ID
                                    FROM @Convey
                                )
                    )
                INSERT INTO dbo.IncomeDistrTable(ID_ID_INCOME, ID_ID_DISTR, ID_PRICE, ID_DATE, ID_ID_PERIOD, ID_PREPAY, ID_ACTION)
                SELECT @Id, DIS_ID, ID_PRICE, @Date, PR_ID, ID_PREPAY, ID_ACTION
                FROM @Convey;
        END;



        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Raw].[Income@Process] TO rl_income_w;
GO
