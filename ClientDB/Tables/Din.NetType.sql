USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Din].[NetType]
(
        [NT_ID]          Int            Identity(1,1)   NOT NULL,
        [NT_NAME]        VarChar(100)                   NOT NULL,
        [NT_NOTE]        VarChar(50)                    NOT NULL,
        [NT_NET]         SmallInt                       NOT NULL,
        [NT_TECH]        SmallInt                       NOT NULL,
        [NT_SHORT]       VarChar(20)                        NULL,
        [NT_ID_MASTER]   Int                                NULL,
        [NT_COEF]        decimal                            NULL,
        [NT_VMI_COEF]    decimal                            NULL,
        [NT_VMI_SHORT]   VarChar(50)                        NULL,
        [NT_TECH_USR]    VarChar(20)                        NULL,
        [NT_ODON]        SmallInt                           NULL,
        [NT_ODOFF]       SmallInt                           NULL,
        CONSTRAINT [PK_Din.NetType] PRIMARY KEY CLUSTERED ([NT_ID]),
        CONSTRAINT [FK_Din.NetType(NT_ID_MASTER)_Din.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([NT_ID_MASTER]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID])
);
GO
