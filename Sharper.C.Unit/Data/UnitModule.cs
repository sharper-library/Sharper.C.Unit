using System;

namespace Sharper.C.Data
{

    public sealed class Unit
    {
        private Unit()
        {
        }

        public static Unit UNIT
        => null;

        public static Action ToAction(Func<Unit> f)
        =>
            () => f();

        public static Action<A> ToAction<A>(Func<A, Unit> f)
        =>
            a => f(a);

        public static Func<Unit> ToFunc(Action action)
        =>
            () =>
            {
                action();
                return UNIT;
            };

        public static Func<A, Unit> ToFunc<A>(Action<A> action)
        =>
            a =>
            {
                action(a);
                return UNIT;
            };

        public static void Void<A>(A a)
        {
        }
    }
}
