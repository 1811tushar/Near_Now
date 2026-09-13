"use client";

import {useEffect} from 'react';

export function ThemeProvider({children}:{children:React.ReactNode}) {
  useEffect(() => {
    const stored = window.localStorage.getItem('nearnow-theme');
    const dark = stored === 'dark' || (!stored && window.matchMedia('(prefers-color-scheme: dark)').matches);
    document.documentElement.classList.toggle('theme-dark', dark);
    document.documentElement.classList.toggle('theme-light', !dark);
  }, []);

  return <>{children}</>;
}
